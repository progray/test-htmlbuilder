unit uDemo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, DBClient, uHTMLBuilder, ShellAPI;

type
  TfrmDemo = class(TForm)
    btnSampleDataSet: TButton;
    cdsProducts: TClientDataSet;
    cdsProductsproduct: TStringField;
    cdsProductsprice: TStringField;
    btnMultiHeader: TButton;
    btnTestList: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSampleDataSetClick(Sender: TObject);
    procedure btnMultiHeaderClick(Sender: TObject);
    procedure btnTestListClick(Sender: TObject);
  private
    { Private declarations }
    procedure PopulateDataSet(dataSet: TDataSet);
    procedure OpenHTMLDocument(report: THTMLReport);
    function GetReportStyle:string;
  public
    { Public declarations }
  end;

var
  frmDemo: TfrmDemo;

implementation

uses Math;

const
  cNUMBER_PRODUCT=50;

{$R *.dfm}

procedure TfrmDemo.PopulateDataSet(dataSet: TDataSet);
var
  i: Integer;
  product, price: TField;
begin
  product := dataSet.FieldByName('product');
  price   := dataSet.FieldByName('price');
  for i := 1 to cNUMBER_PRODUCT do
  begin
    dataSet.Append;
    product.AsString := 'PRODUCT ' + FormatFloat('00', i);
    price.AsString := '$' + FormatFloat('#,###.00', RandomRange(1, cNUMBER_PRODUCT)*10);
    dataSet.Post;
  end;
end;

procedure TfrmDemo.OpenHTMLDocument(report: THTMLReport);
var
  htmlFile: string;
begin
  htmlFile := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'teste.html';
  report.SaveToFile(htmlFile);
  ShellExecute(Handle, 'Open', 'iexplore.exe', PChar(htmlFile), '', SW_SHOWNORMAL);
end;

function TfrmDemo.GetReportStyle:string;
var
  style: TStringList;
begin
  style := TStringList.Create;
  try
    style.Clear;
    style.Add('* {font-family:Arial;font-size:11pt}');
    style.Add('html, body {height:100%;}');
    style.Add('table {width:100% ;border-collapse: collapse;}');
    Result := style.Text;
  finally
    style.Free;
  end;
end;

procedure TfrmDemo.FormCreate(Sender: TObject);
begin
  cdsProducts.CreateDataSet;
  PopulateDataSet(cdsProducts);
end;

procedure TfrmDemo.btnSampleDataSetClick(Sender: TObject);
const
  cPARAGRAPH_STYLE='style="font-weight:bold;font-size:15pt;text-align:center;"';
var
  html: THTMLReport;
  table: THTMLTable;
begin
  html := THTMLReport.Create(GetReportStyle);
  table := THTMLTable.Create;
  try
    table.SetDataSet(cdsProducts, '#909090', '#FFFFFF', '#D0D0D0');
    html.AddParagraph('Test using dataset', cPARAGRAPH_STYLE);
    html.AddTable(table);
    OpenHTMLDocument(html);
  finally
    FreeAndNil(html);
  end;
end;

procedure TfrmDemo.btnMultiHeaderClick(Sender: TObject);
const
  cPARAGRAPH_STYLE='style="font-weight:bold;font-size:15pt;text-align:center;"';
  cHEADER_STYLE='style="font-weight:bold;background-color:silver"';
var
  html: THTMLReport;
  table: THTMLTable;
  product, price: THTMLCell;
  discount10, discount5, fullprice: THTMLCell;
  priceValue: Integer;
  i: Integer;
begin
  html := THTMLReport.Create(GetReportStyle);
  try                  
    table := THTMLTable.Create('border="1px solid black"');
    product    := THTMLCell.Create('Product', 'rowspan=2 ' + cHEADER_STYLE);
    price      := THTMLCell.Create('Price', 'colspan=3 align=center ' + cHEADER_STYLE);
    discount10 := THTMLCell.Create('10% discount', 'width="15%" ' + cHEADER_STYLE);
    discount5  := THTMLCell.Create('5% discount', 'width="15%" ' + cHEADER_STYLE);
    fullprice  := THTMLCell.Create('full price', 'width="20%" ' + cHEADER_STYLE);
    //header
    table.AddRow([product, price], '');
    //sub header
    table.AddRow([fullprice, discount5, discount10], '');
    //lines
    for i := 1 to cNUMBER_PRODUCT do
    begin
      priceValue := RandomRange(1, cNUMBER_PRODUCT)*10;
      table.AddRow([THTMLCell.Create('PRODUCT'+IntToStr(i), ''),
        THTMLCell.Create('$' + FormatFloat('#,###.00', priceValue), ''),
        THTMLCell.Create('$' + FormatFloat('#,###.00', (priceValue*0.95)), ''),
        THTMLCell.Create('$' + FormatFloat('#,###.00', (priceValue*0.9)), '')], '');
    end;

    html.AddParagraph('Test using multi header', cPARAGRAPH_STYLE);
    html.AddTable(table);
    OpenHTMLDocument(html);
  finally
    FreeAndNil(html);
  end;
end;

procedure TfrmDemo.btnTestListClick(Sender: TObject);
const
  cPARAGRAPH_STYLE='style="font-weight:bold;font-size:15pt;text-align:center;"';
var
  html: THTMLReport;
  List1: THTMLList;
  List2: THTMLList;
  NestedList: THTMLList;
  Table: THTMLTable;
  i: Integer;
begin
  html := THTMLReport.Create(GetReportStyle);
  try
    html.AddParagraph('Test List Features', cPARAGRAPH_STYLE);
    
    html.AddParagraph('1. Unordered List (String Items)', 'style="font-weight:bold;margin-top:20px;"');
    List1 := html.AddList(False, 'style="color:blue;"');
    for i := 1 to 3 do
      List1.AddItem('Item ' + IntToStr(i) + ' - Simple Text');
    
    html.AddParagraph('2. Ordered List', 'style="font-weight:bold;margin-top:20px;"');
    List2 := html.AddList(True, 'style="color:green;"');
    for i := 1 to 3 do
      List2.AddItem('Step ' + IntToStr(i) + ' - Ordered Item');
    
    html.AddParagraph('3. Nested List', 'style="font-weight:bold;margin-top:20px;"');
    List1 := html.AddList(False);
    List1.AddItem('Main Item 1');
    List1.AddItem('Main Item 2');
    NestedList := THTMLList.Create(False);
    NestedList.AddItem('Sub Item A');
    NestedList.AddItem('Sub Item B');
    List1.AddItem(NestedList);
    List1.AddItem('Main Item 3');
    
    html.AddParagraph('4. List with Nested Table', 'style="font-weight:bold;margin-top:20px;"');
    List1 := html.AddList(False);
    List1.AddItem('Products List:');
    Table := THTMLTable.Create('border="1px solid black"');
    for i := 1 to 3 do
      Table.AddRow([THTMLCell.Create('Product ' + IntToStr(i), ''),
        THTMLCell.Create('$' + IntToStr(i * 100), '')], '');
    List1.AddItem(Table);
    List1.AddItem('End of List');
    
    html.AddParagraph('5. Deep Nested Lists', 'style="font-weight:bold;margin-top:20px;"');
    List1 := html.AddList(False);
    List1.AddItem('Level 1 - Item 1');
    NestedList := THTMLList.Create(True);
    NestedList.AddItem('Level 2 - Item A');
    List2 := THTMLList.Create(False);
    List2.AddItem('Level 3 - Item X');
    List2.AddItem('Level 3 - Item Y');
    NestedList.AddItem(List2);
    NestedList.AddItem('Level 2 - Item B');
    List1.AddItem(NestedList);
    List1.AddItem('Level 1 - Item 2');
    
    OpenHTMLDocument(html);
  finally
    FreeAndNil(html);
  end;
end;
end.
