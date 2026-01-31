program SimpleTest;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  uHTMLBuilder in 'src\uHTMLBuilder.pas';

var
  Cell: THTMLCell;
  buildable: IHTMLBuildable;
begin
  try
    // 创建一个简单的单元格
    Cell := THTMLCell.Create('Test Cell', '');
    try
      // 检查是否支持接口
      if Supports(Cell, IHTMLBuildable, buildable) then
      begin
        WriteLn('Interface supported!');
        WriteLn('Build result: ', buildable.Build);
      end
      else
      begin
        WriteLn('Interface not supported!');
      end;
    finally
      Cell.Free;
    end;
    
    WriteLn('Test completed successfully!');
  except
    on E: Exception do
      WriteLn('Error: ' + E.Message);
  end;
  
  ReadLn;
end.