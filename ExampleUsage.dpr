program ExampleUsage;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  uHTMLBuilder in 'src\uHTMLBuilder.pas';

// 示例：如何使用重构后的 HTMLBuilder
procedure Example;
var
  Report: THTMLReport;
  Table: THTMLTable;
  Row: THTMLRow;
  Cell: THTMLCell;
  Item: THTMLItem;
  Paragraph: THTMLParagraph;
begin
  // 创建报告
  Report := THTMLReport.Create;
  try
    // 添加标题段落
    Paragraph := Report.AddParagraph('HTML Builder 示例', 'style="font-size:16px;font-weight:bold;text-align:center;"');
    
    // 创建表格
    Table := THTMLTable.Create('border="1" cellpadding="5"');
    try
      // 添加表头
      Row := Table.AddRow('header', 'style="background-color:#f0f0f0;"');
      Cell := Row.AddCell('姓名', 'style="font-weight:bold;"');
      Cell := Row.AddCell('年龄', 'style="font-weight:bold;"');
      Cell := Row.AddCell('职业', 'style="font-weight:bold;"');
      
      // 添加数据行
      Row := Table.AddRow('row1', '');
      Cell := Row.AddCell('张三', '');
      Cell := Row.AddCell('30', '');
      Cell := Row.AddCell('工程师', '');
      
      Row := Table.AddRow('row2', '');
      Cell := Row.AddCell('李四', '');
      Cell := Row.AddCell('25', '');
      Cell := Row.AddCell('设计师', '');
      
      // 添加表格到报告
      Report.AddTable(Table);
    finally
      // 表格由报告自动释放，不需要在这里释放
    end;
    
    // 添加自定义 HTML 项
    Item := THTMLItem.Create('<hr style="margin:20px 0;"');
    Report.AddItem(Item);
    
    // 添加另一个段落
    Paragraph := Report.AddParagraph('这是使用重构后的 HTMLBuilder 生成的报告。', 'style="margin-top:20px;"');
    
    // 生成 HTML
    WriteLn('HTML 报告已生成:');
    WriteLn(Report.Build);
    
    // 保存到文件
    Report.SaveToFile('example_report.html');
    WriteLn('报告已保存到 example_report.html');
  finally
    Report.Free;
  end;
end;

begin
  try
    Example;
  except
    on E: Exception do
      WriteLn('错误: ', E.Message);
  end;
  
  ReadLn;
end.