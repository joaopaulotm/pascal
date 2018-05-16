unit ufrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, System.Types,IniFiles,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.UI, FireDAC.Phys.IBBase,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, Winapi.ActiveX, Vcl.ComCtrls, FileCtrl, IOUtils,
  System.Zip, Threading, DateUtils, Vcl.Samples.Gauges, Vcl.ExtCtrls, ShellApi;

type
  TfrmPrincipal = class(TForm)
    edtOrigem: TEdit;
    edtDestino: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    rg1: TRadioGroup;
    rg2: TRadioGroup;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DirOrigem : string;
    DirDestino : string;
    function CopiaTudo(Origen,Destino : String) : LongInt;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

function FileTimeToDTime(FTime: TFileTime): TDateTime;
var
  LocalFTime: TFileTime;
  STime: TSystemTime;
begin
  FileTimeToLocalFileTime(FTime, LocalFTime);
  FileTimeToSystemTime(LocalFTime, STime);
  Result := SystemTimeToDateTime(STime);
end;

procedure TfrmPrincipal.BitBtn1Click(Sender: TObject);
begin
  SelectDirectory('Escolha a origem da cópia', '%', DirOrigem);
  edtOrigem.Text := DirOrigem + '\';
end;

procedure TfrmPrincipal.BitBtn2Click(Sender: TObject);
begin
  SelectDirectory('Escolha o destino da cópia', '%', DirDestino);
  edtDestino.Text := DirDestino + '\';
end;

procedure TfrmPrincipal.BitBtn3Click(Sender: TObject);
var
    SR: TSearchRec;
    I: integer;
    Origem, Destino: string;
    CreateDT, AccessDT, ModifyDT: TDateTime;
begin
  //CopiaTudo(edtOrigem.Text + '*.pdf', edtDestino.Text);
  I := FindFirst(edtOrigem.Text+rg2.Items[rg2.ItemIndex], faAnyFile, SR);
  while I = 0 do
  begin
    if (SR.Attr and faDirectory) <> faDirectory then
    begin
      CreateDT := FileTimeToDTime(SR.FindData.ftCreationTime);
      if YearOf(CreateDT) < StrToInt(rg1.Items[rg1.ItemIndex]) then
      begin
        Origem  := edtOrigem.Text + SR.Name;
        Destino := edtDestino.Text + SR.Name;
        if not MoveFile(PChar(Origem), PChar(Destino)) then
          ShowMessage('Erro ao copiar ' + Origem + ' para ' + Destino);
      end;
    end;
    I := FindNext(SR);
  end;
  ShowMessage('Cópia dos arquivos concluída!');
end;

function TfrmPrincipal.CopiaTudo(Origen, Destino: String): LongInt;
var
Mensagem : String;
F : TShFileOpStruct;
sOrigen, sDestino : String;
begin
  Result := 0;
  sOrigen := Origen + #0;
  sDestino := Destino + #0;
  With F do
  begin
    Wnd := Application.Handle;
    wFunc := FO_COPY;
    pFrom := @sOrigen[1];
    pTo := @sDestino[1];
    fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION
  end;
  Result := ShFileOperation(F);
end;

end.
