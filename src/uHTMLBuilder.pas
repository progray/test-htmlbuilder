unit uHTMLBuilder;

interface

uses
  Classes, Contnrs, SysUtils, DB;

type
  IHTMLBuildable = interface
    ['{4A8F4A7D-7E6B-4F3A-9C1D-8E7B6A5C4D3E}']
    function Build: string;
  end;

  THTMLBase = class(TInterfacedObject, IHTMLBuildable)
  protected
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    function Build: string; virtual; abstract;
  end;

  THTMLCell = class(THTMLBase, IHTMLBuildable)
  private
    Fstyle: string;
    FName: string;
    FItemList: TObjectList;
    procedure Initialize(cellName: string = ''; cellStyle: string = '');
  protected
  public
    property Style: string read FStyle write FStyle;
    property Name: string read FName write FName;
    property ItemList: TObjectList read FItemList write FItemList;
    function Build: string; override;
    constructor Create; overload;
    constructor Create(cellName, cellStyle: string); overload;
    destructor Destroy; override;
  end;

  TAfterAddRow = procedure(
    Table: THTMLBase;
    DataSet: TDataSet
  ) of object;

  THTMLItem = class(THTMLBase, IHTMLBuildable)
  private
    FHtml: TStringList;
  protected
  public
    property HTML: TStringList read FHtml write FHtml;
    function Build: string; override;
    constructor Create(itemHtml: string = '');
    destructor Destroy; override;
  end;

  THTMLParagraph = class(THTMLBase, IHTMLBuildable)
  private
    Fstyle: string;
    FName: string;
    FItemList: TObjectList;
    procedure Initialize(paragraphName: string = ''; style: string = '');
  protected
  public
    property Style: string read FStyle write FStyle;
    property Name: string read FName write FName;
    property ItemList: TObjectList read FItemList write FItemList;
    function Build: string; override;
    constructor Create; overload;
    constructor Create(paragraphName, style: string); overload;
    destructor Destroy; override;
  end;

  THTMLRow = class(THTMLBase, IHTMLBuildable)
  private
    Fstyle: string;
    FName: string;
    FCellList: TObjectList;
    procedure Initialize(rowCellList: array of THTMLCell; rowStyle: string = '');
  protected
  public
    property Style: string read FStyle write FStyle;
    property Name: string read FName write FName;
    property CellList: TObjectList read FCellList write FCellList;
    function Build: string; override;
    function AddCell(cellName, cellStyle: string): THTMLCell;
    constructor Create; overload;
    constructor Create(rowCellList: array of THTMLCell); overload;
    constructor Create(rowCellList: array of THTMLCell; rowStyle: string); overload;
    destructor Destroy; override;
  end;

  THTMLTable = class(THTMLBase, IHTMLBuildable)
  private
    FRowList: TObjectList;
    Fstyle: string;
  protected
  public
    property Style: string read FStyle write FStyle;
    property RowList: TObjectList read FRowList write FRowList;
    function AddRow(cellList: array of THTMLCell; rowStyle: string): THTMLRow; overload;
    function AddRow(rowName, rowStyle: string): THTMLRow; overload;
    function AddEmptyRow(rowStyle: string = ''): THTMLRow;
    function Build: string; override;
    procedure SetDataSet(dataSet: TDataSet;
      HeaderColor: string = '';
      EvenColor: string = '';
      OddColor: string = '';
      EmptyValue: string = '';
      AfterAddRow: TAfterAddRow = nil);
    constructor Create(tableStyle: string = '');
    destructor Destroy; override;
  end;

  THTMLReport = class(THTMLBase, IHTMLBuildable)
  private
    FHTMLItemList: TObjectList;
    FStyle: string;
    FStyleHTML: string;
    FHead: string;
    function BuildDefaultStyle: string;
    procedure Initialize(reportStyle: string = '');
  protected
    procedure SetStyle(value: string);
  public
    property HTMLItemList: TObjectList read FHTMLItemList write FHTMLItemList;
    property Style: string read FStyle write SetStyle;
    property StyleHTML: string read FStyleHTML write FStyleHTML;
    property Head: string read FHead write FHead;
    procedure AddTable(table: THTMLTable);
    procedure AddItem(item: THTMLItem);
    function AddParagraph(paragraphName, paragraphStyle: string): THTMLParagraph;
    function Build: string; override;
    procedure SaveToFile(fileName: string);
    procedure Clear;
    constructor Create; overload;
    constructor Create(reportStyle: string); overload;
    destructor Destroy; override;
  end;

  TBuild = class
  public
    class function Build(item: IHTMLBuildable): string;
  end;

implementation

{ THTMLBase }

function THTMLBase._AddRef: Integer;
begin
  Result := -1;
end;

function THTMLBase._Release: Integer;
begin
  Result := -1;
end;

{ THTMLTable }

function THTMLTable.AddRow(cellList: array of THTMLCell;
  rowStyle: string): THTMLRow;
var
  row: THTMLrow;
  i: Integer;
begin
  row := THTMLrow.Create;
  row.Style := rowStyle;
  for i := 0 to High(cellList) do
    row.CellList.Add(cellList[i]);
  FRowList.Add(row);
  Result := row;
end;

function THTMLTable.AddEmptyRow(rowStyle: string = ''): THTMLRow;
var
  row: THTMLrow;
begin
  row := THTMLrow.Create;
  row.Style := rowStyle;
  row.CellList.Add(THTMLCell.Create(' ', 'colspan="100%"'));
  FRowList.Add(row);
  Result := row;
end;

function THTMLTable.Build: string;
var
  i: Integer;
  html: TStringList;
begin
  html := TStringList.Create;
  try
    html.Clear;
    html.Add('<table ' + Self.Style + '>');
    for i := 0 to FRowList.Count - 1 do
      html.Add(TBuild.Build(THTMLRow(FRowList[i])));
    html.Add('</table>');
    Result := html.Text;
  finally
    FreeAndNil(html);
  end;
end;

constructor THTMLTable.Create(tableStyle: string = '');
begin
  inherited Create;
  RowList := TObjectList.Create(True);
  Style := tableStyle;
end;

destructor THTMLTable.Destroy;
begin
  FreeAndNil(FRowList);
  inherited Destroy;
end;

function THTMLTable.AddRow(rowName, rowStyle: string): THTMLRow;
begin
  Result := THTMLRow.Create;
  Result.Name := rowName;
  Result.Style := rowStyle;
  RowList.Add(Result);
end;

procedure THTMLTable.SetDataSet(
  dataSet: TDataSet; HeaderColor: string = '';
  EvenColor: string = ''; OddColor: string = '';
  EmptyValue: string = ''; AfterAddRow: TAfterAddRow = nil);
const
  StyleHeader = '';
  StyleData = '';
var
  i: Integer;
  row: THTMLRow;
  cell: THTMLCell;
begin
  row := THTMLRow.Create;
  row.Style := 'bgcolor="' + HeaderColor + '"';
  for i := 0 to dataSet.FieldCount - 1 do
    if dataSet.Fields[i].Visible then
      row.AddCell('<b>' + dataSet.Fields[i].DisplayName + '</b>', StyleHeader);
  Self.RowList.Add(row);
  dataSet.DisableControls;
  try
    dataSet.First;
    while not dataSet.Eof do
    begin
      row := THTMLRow.Create;
      if ((dataSet.RecNo mod 2) <> 0) then
        row.Style := 'bgcolor="' + EvenColor + '"'
      else
        row.Style := 'bgcolor="' + OddColor + '"';

      for i := 0 to dataSet.FieldCount - 1 do
        if dataSet.Fields[i].Visible then
        begin
          if dataSet.FieldByName(dataSet.Fields[i].FieldName).DataType = ftMemo then
            cell := row.AddCell(dataSet.FieldByName(dataSet.Fields[i].FieldName).AsString, StyleData)
          else
            cell := row.AddCell(dataSet.FieldByName(dataSet.Fields[i].FieldName).DisplayText, StyleData);

          if cell.Name = EmptyStr then
            cell.Name := EmptyValue;
        end;
      Self.RowList.Add(row);
      if Assigned(AfterAddRow) then
        AfterAddRow(Self, dataSet);

      dataSet.Next;
    end;
  finally
    dataSet.EnableControls;
  end;
end;

{ THTMLCell }

constructor THTMLCell.Create(cellName, cellStyle: string);
begin
  inherited Create;
  Initialize(cellName, cellStyle);
end;

function THTMLCell.Build: string;
var
  html: TStringList;
  i: Integer;
begin
  html := TStringList.Create;
  try
    html.Add('    <td ' + Self.Style + '>');
    if Self.Name <> '' then
      html.Add('      ' + Self.Name);
    for i := 0 to Self.ItemList.Count - 1 do
      html.Add('      ' + TBuild.Build(THTMLBase(FItemList[i])));
    html.Add('    </td>');
    Result := html.Text;
  finally
    FreeAndNil(html);
  end;
end;

destructor THTMLCell.Destroy;
begin
  FreeAndNil(FItemList);
  inherited Destroy;
end;

constructor THTMLCell.Create;
begin
  inherited Create;
  Initialize;
end;

procedure THTMLCell.Initialize(cellName: string = ''; cellStyle: string = '');
begin
  FItemList := TObjectList.Create(True);
  Name := cellName;
  Style := cellStyle;
end;

{ THTMLRow }

function THTMLRow.AddCell(cellName, cellStyle: string): THTMLCell;
begin
  Result := THTMLCell.Create(cellName, cellStyle);
  CellList.Add(Result);
end;

function THTMLRow.Build: string;
var
  i: Integer;
  html: TStringList;
begin
  html := TStringList.Create;
  try
    html.Clear;
    html.Add('  <tr ' + Self.Style + ' >');
    for i := 0 to Self.CellList.Count - 1 do
    begin
      html.Add(TBuild.Build(THTMLCell(FCellList[i])));
    end;
    html.Add('  </tr>');
    Result := html.Text;
  finally
    FreeAndNil(html);
  end;
end;

constructor THTMLRow.Create;
begin
  inherited Create;
  Initialize([]);
end;

constructor THTMLRow.Create(rowCellList: array of THTMLCell);
begin
  inherited Create;
  Initialize(rowCellList);
end;

constructor THTMLRow.Create(rowCellList: array of THTMLCell;
  rowStyle: string);
begin
  inherited Create;
  Initialize(rowCellList, rowStyle);
end;

destructor THTMLRow.Destroy;
begin
  FreeAndNil(FCellList);
  inherited Destroy;
end;

procedure THTMLRow.Initialize(rowCellList: array of THTMLCell;
  rowStyle: string = '');
var
  i: Integer;
begin
  FCellList := TObjectList.Create(True);
  Self.Style := rowStyle;
  for i := 0 to High(rowCellList) do
    CellList.Add(rowCellList[i]);
end;

{ THTMLReport }

procedure THTMLReport.AddItem(item: THTMLItem);
begin
  HTMLItemList.Add(item);
end;

function THTMLReport.AddParagraph(paragraphName,
  paragraphStyle: string): THTMLParagraph;
begin
  Result := THTMLParagraph.Create(paragraphName, paragraphStyle);
  HTMLItemList.Add(Result);
end;

procedure THTMLReport.AddTable(table: THTMLTable);
begin
  HTMLItemList.Add(table);
end;

function THTMLReport.Build: string;
var
  i: Integer;
  html: TstringList;
begin
  html := TStringList.Create;
  try
    html.Clear;
    html.Add('<html ' + StyleHTML + '>');
    html.Add('  <head>');
    html.Add('    <style>');
    html.Add(Self.Style);
    html.Add('    </style>');
    html.Add('    ' + Self.Head);
    html.Add('  </head>');
    html.Add('  <body>');
    for i := 0 to HTMLItemList.Count - 1 do
      html.Add(TBuild.Build(THTMLBase(FHTMLItemList[i])));
    html.Add('  </body>');
    html.Add('</html>');
    Result := html.Text;
  finally
    FreeAndNil(html);
  end;
end;

constructor THTMLReport.Create;
begin
  inherited Create;
  Initialize;
end;

function THTMLReport.BuildDefaultStyle: string;
var
  html: TStringList;
begin
  html := TStringList.Create;
  try
    html.Clear;
    html.Add('html, body {height:100%;}');
    html.Add('table {width:100% ;border-collapse: collapse;font-family:Arial;font-size:8pt}');
    Result := html.Text;
  finally
    FreeAndNil(html);
  end;
end;

procedure THTMLReport.Clear;
begin
  FHTMLItemList.Clear;
end;

constructor THTMLReport.Create(reportStyle: string);
begin
  inherited Create;
  Initialize(reportStyle);
end;

destructor THTMLReport.Destroy;
begin
  FreeAndNil(FHTMLItemList);
  inherited Destroy;
end;

procedure THTMLReport.SaveToFile(fileName: string);
var
  toFile: TStringList;
begin
  toFile := TStringList.Create;
  try
    toFile.Text := Self.Build;
    toFile.SaveToFile(fileName);
  finally
    FreeAndNil(toFile);
  end;
end;

procedure THTMLReport.SetStyle(value: string);
begin
  if value = '' then
    FStyle := BuildDefaultStyle
  else
    FStyle := value;
end;

procedure THTMLReport.Initialize(reportStyle: string = '');
begin
  FHTMLItemList := TObjectList.Create(True);
  Style := reportStyle;
  StyleHTML := '';
  Head := '';
end;

{ THTMLItem }

function THTMLItem.Build: string;
begin
  Result := HTML.Text;
end;

constructor THTMLItem.Create(itemHtml: string);
begin
  inherited Create;
  fHTML := TStringList.Create;
  fHTML.Clear;
  fHTML.Text := itemHtml;
end;

destructor THTMLItem.Destroy;
begin
  FreeAndNil(fHTML);
  inherited Destroy;
end;

{ TBuild }

class function TBuild.Build(item: IHTMLBuildable): string;
begin
  Result := item.Build;
end;

{ THTMLParagraph }

constructor THTMLParagraph.Create;
begin
  inherited Create;
  Initialize;
end;

function THTMLParagraph.Build: string;
var
  html: TStringList;
  i: Integer;
begin
  html := TStringList.Create;
  try
    html.Clear;
    html.Add('<p ' + Style + '>');
    html.Add(Self.Name);
    for i := 0 to Self.ItemList.Count - 1 do
      html.Add(TBuild.Build(THTMLBase(FItemList[i])));
    html.Add('</p>');
    Result := html.Text;
  finally
    FreeAndNil(html);
  end;
end;

constructor THTMLParagraph.Create(paragraphName, style: string);
begin
  inherited Create;
  Initialize(paragraphName, style);
end;

destructor THTMLParagraph.Destroy;
begin
  FreeAndNil(FItemList);
  inherited Destroy;
end;

procedure THTMLParagraph.Initialize(paragraphName: string = ''; style: string = '');
begin
  FItemList := TObjectList.Create(True);
  Self.Name := paragraphName;
  Self.Style := style;
end;

end.
