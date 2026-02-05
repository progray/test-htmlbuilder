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
    btnListTest: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSampleDataSetClick(Sender: TObject);
    procedure btnMultiHeaderClick(Sender: TObject);
    procedure btnListTestClick(Sender: TObject);
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

procedure TfrmDemo.btnListTestClick(Sender: TObject);
const
  cPARAGRAPH_STYLE='style="font-weight:bold;font-size:15pt;text-align:center;"';
  cLIST_STYLE='style="margin-left:20px;"';
var
  html: THTMLReport;
  ulList: THTMLList;
  olList: THTMLList;
  nestedList: THTMLList;
  table: THTMLTable;
  cell: THTMLCell;
begin
  html := THTMLReport.Create(GetReportStyle);
  try
    // Test 1: Simple unordered list with text items
    html.AddParagraph('Test 1: Simple Unordered List', cPARAGRAPH_STYLE);
    ulList := THTMLList.Create(False, cLIST_STYLE);
    ulList.AddItem('First item');
    ulList.AddItem('Second item');
    ulList.AddItem('Third item');
    html.HTMLItemList.Add(ulList);

    // Test 2: Ordered list with text items
    html.AddParagraph('Test 2: Ordered List', cPARAGRAPH_STYLE);
    olList := THTMLList.Create(True, cLIST_STYLE);
    olList.AddItem('Step 1: Initialize');
    olList.AddItem('Step 2: Process');
    olList.AddItem('Step 3: Finalize');
    html.HTMLItemList.Add(olList);

    // Test 3: Nested list - list inside list
    html.AddParagraph('Test 3: Nested List (List inside List)', cPARAGRAPH_STYLE);
    ulList := THTMLList.Create(False, cLIST_STYLE);
    ulList.AddItem('Fruits');
    nestedList := THTMLList.Create(False, cLIST_STYLE);
    nestedList.AddItem('Apple');
    nestedList.AddItem('Banana');
    nestedList.AddItem('Orange');
    ulList.AddItem(nestedList, True);
    ulList.AddItem('Vegetables');
    nestedList := THTMLList.Create(False, cLIST_STYLE);
    nestedList.AddItem('Carrot');
    nestedList.AddItem('Potato');
    ulList.AddItem(nestedList, True);
    html.HTMLItemList.Add(ulList);

    // Test 4: List inside table cell
    html.AddParagraph('Test 4: List inside Table Cell', cPARAGRAPH_STYLE);
    table := THTMLTable.Create('border="1px solid black"');
    cell := THTMLCell.Create('Cell with list:', '');
    ulList := THTMLList.Create(False, '');
    ulList.AddItem('Item A');
    ulList.AddItem('Item B');
    ulList.AddItem('Item C');
    cell.ItemList.Add(ulList);
    table.AddRow([cell, THTMLCell.Create('Normal cell', '')], '');
    html.AddTable(table);

    // Test 5: Complex nested structure - Table inside list item
    html.AddParagraph('Test 5: Table inside List Item', cPARAGRAPH_STYLE);
    ulList := THTMLList.Create(False, cLIST_STYLE);
    ulList.AddItem('Regular text item');
    table := THTMLTable.Create('border="1px solid black"');
    table.AddRow([THTMLCell.Create('Col1', ''), THTMLCell.Create('Col2', '')], '');
    table.AddRow([THTMLCell.Create('Data1', ''), THTMLCell.Create('Data2', '')], '');
    ulList.AddItem(table, True);
    ulList.AddItem('Another text item');
    html.HTMLItemList.Add(ulList);

    OpenHTMLDocument(html);
  finally
    FreeAndNil(html);
  end;
end;

end.
