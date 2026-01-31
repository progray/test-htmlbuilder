# HTMLBuilder 重构说明

## 重构概述

HTMLBuilder 库已经成功重构，引入了接口机制以解决硬编码问题并遵循开闭原则。

## 主要改进

### 1. 引入 IHTMLBuildable 接口

```pascal
IHTMLBuildable = interface
  ['{B3F1E2D4-8A9C-4D5F-B1E7-3C9A8F5D2E1B}']
  function Build: string;
end;
```

### 2. 创建非引用计数的接口基类

为了解决接口引用计数与 TObjectList 兼容性问题，创建了 `TNonRefCountedInterfacedObject` 类：

```pascal
TNonRefCountedInterfacedObject = class(TObject, IInterface)
protected
  function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  function _AddRef: Integer; stdcall;
  function _Release: Integer; stdcall;
end;
```

该类实现了接口但禁用了引用计数，确保对象生命周期仍然由 TObjectList 管理。

### 3. 重构所有组件类实现 IHTMLBuildable 接口

所有组件类现在都继承自 `TNonRefCountedInterfacedObject` 并实现 `IHTMLBuildable` 接口：
- THTMLCell
- THTMLItem
- THTMLParagraph
- THTMLRow
- THTMLTable
- THTMLReport

### 4. 重构 TBuild.Build 方法

原来的硬编码类型判断被替换为基于接口的动态调用：

```pascal
class function TBuild.Build(item: TObject): string;
var
  buildable: IHTMLBuildable;
begin
  if Supports(item, IHTMLBuildable, buildable) then
    Result := buildable.Build
  else
    Result := '';
end;
```

## 添加新组件的步骤

现在，添加新的 HTML 组件只需：

1. 创建新类继承自 `TNonRefCountedInterfacedObject`
2. 实现 `IHTMLBuildable` 接口
3. 无需修改 `TBuild.Build` 方法

### 示例：添加 THTMLDiv 组件

```pascal
THTMLDiv = class(TNonRefCountedInterfacedObject, IHTMLBuildable)
private
  FStyle: string;
  FContent: string;
  FItemList: TObjectList;
public
  property Style: string read FStyle write FStyle;
  property Content: string read FContent write FContent;
  property ItemList: TObjectList read FItemList write FItemList;
  
  function Build: string;
  constructor Create(divStyle: string = ''; divContent: string = '');
  destructor Destroy; override;
  
  function AddItem(item: TObject): IHTMLBuildable;
end;

// 实现部分
constructor THTMLDiv.Create(divStyle: string = ''; divContent: string = '');
begin
  FItemList := TObjectList.Create;
  FStyle := divStyle;
  FContent := divContent;
end;

destructor THTMLDiv.Destroy;
begin
  FreeAndNil(FItemList);
  inherited;
end;

function THTMLDiv.Build: string;
var
  i: Integer;
  html: TStringList;
begin
  html := TStringList.Create;
  try
    html.Add('<div ' + FStyle + '>');
    if FContent <> '' then
      html.Add('  ' + FContent);
    
    for i := 0 to FItemList.Count - 1 do
      html.Add('  ' + TBuild.Build(FItemList[i]));
      
    html.Add('</div>');
    Result := html.Text;
  finally
    FreeAndNil(html);
  end;
end;

function THTMLDiv.AddItem(item: TObject): IHTMLBuildable;
begin
  FItemList.Add(item);
  if Supports(item, IHTMLBuildable, Result) then
    // 接口支持
  else
    Result := nil;
end;
```

## 兼容性保证

通过使用非引用计数的接口基类，我们确保了：
- 对象生命周期仍然由 TObjectList 管理
- 不会发生双重释放问题
- 现有代码无需修改即可继续工作

## 总结

重构后的代码更加灵活、可维护，并且为未来的扩展提供了良好的基础。新组件的添加不再需要修改核心构建逻辑，大大降低了代码耦合度，完全符合开闭原则。