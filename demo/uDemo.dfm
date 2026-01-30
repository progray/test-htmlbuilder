object frmDemo: TfrmDemo
  Left = 313
  Top = 176
  Caption = 'frmDemo'
  ClientHeight = 145
  ClientWidth = 199
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 13
  object btnSampleDataSet: TButton
    Left = 24
    Top = 24
    Width = 150
    Height = 25
    Caption = 'DataSet'
    TabOrder = 0
    OnClick = btnSampleDataSetClick
  end
  object btnMultiHeader: TButton
    Left = 24
    Top = 64
    Width = 150
    Height = 25
    Caption = 'Multi Header'
    TabOrder = 1
    OnClick = btnMultiHeaderClick
  end
  object btnListTest: TButton
    Left = 24
    Top = 104
    Width = 150
    Height = 25
    Caption = 'List Test'
    TabOrder = 2
    OnClick = btnListTestClick
  end
  object cdsProducts: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 168
    object cdsProductsproduct: TStringField
      FieldName = 'product'
      Size = 250
    end
    object cdsProductsprice: TStringField
      FieldName = 'price'
      Size = 10
    end
  end
end
