unit TestBuilder;

interface

uses
  Classes, SysUtils, uHTMLBuilder;

type
  TTestBuilder = class
  public
    class function TestInterface: Boolean;
  end;

implementation

{ TTestBuilder }

class function TTestBuilder.TestInterface: Boolean;
var
  Report: THTMLReport;
  Table: THTMLTable;
  Row: THTMLRow;
  Cell: THTMLCell;
  buildable: IHTMLBuildable;
begin
  Result := False;
  
  try
    // 创建报告
    Report := THTMLReport.Create;
    try
      // 创建表格
      Table := THTMLTable.Create;
      try
        // 添加行和单元格
        Row := Table.AddRow('row1', '');
        Cell := Row.AddCell('Cell 1', '');
        
        // 测试接口支持
        if Supports(Report, IHTMLBuildable, buildable) then
          Result := True
        else
          Exit;
          
        if Supports(Table, IHTMLBuildable, buildable) then
          Result := True
        else
          Exit;
          
        if Supports(Row, IHTMLBuildable, buildable) then
          Result := True
        else
          Exit;
          
        if Supports(Cell, IHTMLBuildable, buildable) then
          Result := True
        else
          Exit;
          
        // 测试构建方法
        Report.AddTable(Table);
        if Report.Build <> '' then
          Result := True;
      finally
        Table.Free;
      end;
    finally
      Report.Free;
    end;
  except
    Result := False;
  end;
end;

end.