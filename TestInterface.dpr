program TestInterface;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  uHTMLBuilder in '..\src\uHTMLBuilder.pas';

var
  Report: THTMLReport;
  Table: THTMLTable;
  Row: THTMLRow;
  Cell: THTMLCell;
  Item: THTMLItem;
  Paragraph: THTMLParagraph;
begin
  try
    // 创建报告
    Report := THTMLReport.Create;
    try
      // 创建表格
      Table := THTMLTable.Create('border="1"');
      try
        // 添加行和单元格
        Row := Table.AddRow('row1', '');
        Cell := Row.AddCell('Cell 1', '');
        Cell := Row.AddCell('Cell 2', '');
        
        // 添加表格到报告
        Report.AddTable(Table);
        
        // 创建段落
        Paragraph := Report.AddParagraph('Test Paragraph', 'style="color:red;"');
        
        // 创建HTML项
        Item := THTMLItem.Create('<b>HTML Item</b>');
        Report.AddItem(Item);
        
        // 构建HTML
        WriteLn('HTML Report built successfully!');
        WriteLn(Report.Build);
      finally
        // 表格由报告自动释放，不需要在这里释放
      end;
    finally
      Report.Free;
    end;
    
    WriteLn('Test completed successfully!');
  except
    on E: Exception do
      WriteLn('Error: ' + E.Message);
  end;
  
  ReadLn;
end.