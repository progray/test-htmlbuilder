unit uDemo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, DBClient, uHTMLBuilder, ShellAPI, StrUtils;

type
  TfrmDemo = class(TForm)
    btnSampleDataSet: TButton;
    cdsProducts: TClientDataSet;
    cdsProductsproduct: TStringField;
    cdsProductsprice: TStringField;
    btnMultiHeader: TButton;
    btnCSSClass: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSampleDataSetClick(Sender: TObject);
    procedure btnMultiHeaderClick(Sender: TObject);
    procedure btnCSSClassClick(Sender: TObject);
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
    style.Add('.table-bordered {border: 2px solid #333;}');
    style.Add('.table-striped tr:nth-child(even) {background-color: #f2f2f2;}');
    style.Add('.header-row {background-color: #4CAF50;color: white;}');
    style.Add('.header-cell {font-weight: bold;color: white;}');
    style.Add('.highlight-cell {background-color: #ffeb3b;font-weight: bold;}');
    style.Add('.paragraph-title {font-size: 16pt;font-weight: bold;color: #2196F3;text-align: center;}');
    style.Add('.dataset-header {background-color: #2196F3;color: white;font-weight: bold;}');
    style.Add('.dataset-even {background-color: #e3f2fd;}');
    style.Add('.dataset-odd {background-color: #bbdefb;}');
    style.Add('.dataset-cell {padding: 8px;}');
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
  table.CSSClass := 'table-bordered table-striped';
  table.SetDataSet(cdsProducts, '', '', '', '', nil, 
    'dataset-header', 'dataset-even', 'dataset-odd', 'dataset-cell');
  html.AddParagraph('Test using dataset with CSSClass', cPARAGRAPH_STYLE);
  html.AddTable(table);
  OpenHTMLDocument(html);
  FreeAndNil(html);
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

procedure TfrmDemo.btnCSSClassClick(Sender: TObject);
var
  html: THTMLReport;
  table: THTMLTable;
  row: THTMLRow;
  cell: THTMLCell;
  paragraph: THTMLParagraph;
  i: Integer;
begin
  html := THTMLReport.Create(GetReportStyle);
  try
    paragraph := THTMLParagraph.Create;
    paragraph.CSSClass := 'paragraph-title';
    paragraph.Name := 'CSS Class Test - Bootstrap Style';
    html.AddParagraph(paragraph.Name, '');

    table := THTMLTable.Create;
    table.CSSClass := 'table-bordered table-striped';

    row := THTMLRow.Create;
    row.CSSClass := 'header-row';
    row.AddCell('Product', '');
    row.AddCell('Price', '');
    row.AddCell('Status', '');
    table.RowList.Add(row);

    for i := 1 to 5 do
    begin
      row := THTMLRow.Create;
      cell := row.AddCell('PRODUCT ' + IntToStr(i), '');
      if i = 3 then
        cell.CSSClass := 'highlight-cell';
      row.AddCell('$' + FormatFloat('#,###.00', RandomRange(10, 100)), '');
      row.AddCell(IfThen(i mod 2 = 0, 'Available', 'Sold Out'), '');
      table.RowList.Add(row);
    end;

    html.AddTable(table);
    OpenHTMLDocument(html);
  finally
    FreeAndNil(html);
  end;
end;

end.
