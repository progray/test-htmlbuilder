program TestList;

uses
  SysUtils,
  uHTMLBuilder in '..\src\uHTMLBuilder.pas';

var
  html: THTMLReport;
  unorderedList: THTMLList;
begin
  try
    html := THTMLReport.Create;
    try
      unorderedList := THTMLList.Create(ltUnordered, 'style="color:blue;"');
      unorderedList.AddItem('First item');
      unorderedList.AddItem('Second item');
      unorderedList.AddItem('Third item');
      
      html.AddList(unorderedList);
      
      WriteLn(html.Build);
    finally
      html.Free;
    end;
  except
    on E: Exception do
      WriteLn('Error: ', E.Message);
  end;
end.