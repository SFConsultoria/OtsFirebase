unit Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  System.JSON,
  OtsFirebase.Util;

type
  TfrmMain = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lbResp: TLabel;
    Label8: TLabel;
    edtEmail: TEdit;
    edtPassword: TEdit;
    memoToken: TMemo;
    bLoginUser: TButton;
    memoResp: TMemo;
    edtApiKey: TEdit;
    edtProjectId: TEdit;
    edtNode: TEdit;
    bGetDocument: TButton;
    bCreateUser: TButton;
    bLogout: TButton;
    OtsFirebase: TOtsFirebase;
    noAuth: TCheckBox;
    edtNode2: TEdit;
    edtUrlRequest: TEdit;
    Label5: TLabel;
    btnExecuteOuter: TButton;
    Label9: TLabel;
    edtKeyValue: TEdit;
    btnExecuteFirebase: TButton;
    ComboFiltro: TComboBox;
    edtKey: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    procedure bCreateUserClick(Sender: TObject);
    procedure bLoginUserClick(Sender: TObject);
    procedure bLogoutClick(Sender: TObject);
    procedure bGetDocumentClick(Sender: TObject);
    procedure btnExecuteOuterClick(Sender: TObject);
    procedure btnExecuteFirebaseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.bCreateUserClick(Sender: TObject);
var
  Time1, Time2: TTime;
  Obj         : TJSONObject;
begin
  Time1 := Now;

  { Nota: N�o � necess�rio ficar passando os par�metros do Projeto: GOOGLE_API_KEY, GOOGLE_PROJECT_ID

    Basta fazer o seguinte:
    *************************************************************************************************

    OtsFirebase.API_KEY    := MINHA_API_KEY;
    OtsFirebase.PROJECT_ID := MEU_PROJECT_ID;

    *************************************************************************************************


    Dessa forma sua chamada ficaria assim:

    OtsFirebase.Auth(USUARIO, SENHA, CRIA_OU_NAO_UM_NOVO_USUARIO)... }

  Obj := OtsFirebase.API(edtApiKey.Text, edtProjectId.Text)
          .Auth(edtEmail.Text, edtPassword.Text, TRUE)
          .ToJSONObject();
  // TRUE par�metro opcional para criar um usu�rio

  memoToken.Lines.Clear;
  if UpperCase(Obj.ToJSON).Contains('IDTOKEN') then
    memoToken.Lines.Add(Obj.Values['idToken'].Value);

  memoResp.Text := Obj.ToJSON;

  Time2 := Now - Time1;

  lbResp.Caption := 'Resposta em: ' + FormatDateTime('hh:mm:ss:zzz', Time2);
end;

procedure TfrmMain.bLoginUserClick(Sender: TObject);
var
  Time1, Time2: TTime;
  Obj         : TJSONObject;
begin
  Time1 := Now;

  { Nota: N�o � necess�rio ficar passando os par�metros do Projeto: GOOGLE_API_KEY, GOOGLE_PROJECT_ID

    Basta fazer o seguinte:
    *************************************************************************************************

    OtsFirebase.API_KEY    := MINHA_API_KEY;
    OtsFirebase.PROJECT_ID := MEU_PROJECT_ID;

    *************************************************************************************************


    Dessa forma sua chamada ficaria assim:

    OtsFirebase.Auth(USUARIO, SENHA, CRIA_OU_NAO_UM_NOVO_USUARIO)... }

  memoResp.Text := '';

  Obj := OtsFirebase.API(edtApiKey.Text, edtProjectId.Text)
            .Auth(edtEmail.Text, edtPassword.Text)
            .ToJSONObject();
  // SEM O TRUE esta chamada serve para autenticar um usu�rio na base

  memoToken.Lines.Clear;
  if UpperCase(Obj.ToJSON).Contains('IDTOKEN') then
    memoToken.Lines.Add(Obj.Values['idToken'].Value);

  memoResp.Text := Obj.ToJSON;

  Time2 := Now - Time1;

  lbResp.Caption := 'Resposta em: ' + FormatDateTime('hh:mm:ss:zzz', Time2);
end;

procedure TfrmMain.bLogoutClick(Sender: TObject);
begin
  OtsFirebase.API(edtProjectId.Text)
    .Logout(OtsFirebase.FAuth); // Realizo a saida da conex�o com a base de dados,
  // dessa forma posso obter um novo Token autenticando novamente
  // ****** ESTE N�O RETORNA NADA - N�O TEM NECESSIDADE ******
  memoToken.Text := '';
  memoResp.Text  := '';
end;

procedure TfrmMain.bGetDocumentClick(Sender: TObject);
var
  Time1, Time2: TTime;
begin
  Time1 := Now;

  memoResp.Text := '';

  if noAuth.Checked then
  begin

    // Consumindo um projeto Firebase sem autentica��o, projeto com regras de seguran�a aberta

    memoResp.Text := OtsFirebase.API(edtProjectId.Text)
                        .Database
                        .Resource([edtNode.Text, edtNode2.Text])
                        .Get();

  end
  else
  begin

    // Autenticando e consumindo um Firebase

    OtsFirebase.API(edtApiKey.Text, edtProjectId.Text);

    memoResp.Text := OtsFirebase // .API(edtApiKey.Text, edtProjectId.Text)
      .Auth(edtEmail.Text, edtPassword.Text)
      .Database
      .Resource([edtNode.Text, edtNode2.Text])
      .Get();
  end;

  Time2 := Now - Time1;

  lbResp.Caption := 'Resposta em: ' + FormatDateTime('hh:mm:ss:zzz', Time2);
end;

procedure TfrmMain.btnExecuteFirebaseClick(Sender: TObject);
var
  Time1, Time2: TTime;
begin
  Time1 := Now;

  memoResp.Text := '';

  if noAuth.Checked then
  begin

    // Consumindo um projeto Firebase sem autentica��o,
    // projeto com regras de seguran�a aberta

    case ComboFiltro.ItemIndex of
      0: //startAt
        memoResp.Text := OtsFirebase
                          .API(edtProjectId.Text)
                          .Database.Resource([edtNode.Text])
                          .filterBy(edtKey.Text)
                          .startAt(edtKeyValue.Text)
                          .timeOut()
                          .Get();

      1: //equalTo
        memoResp.Text := OtsFirebase
                          .API(edtProjectId.Text)
                          .Database.Resource([edtNode.Text])
                          .filterBy(edtKey.Text)
                          .equalTo(edtKeyValue.Text)
                          .timeOut()
                          .Get();
    end;

  end
  else
  begin

    // Autenticando e consumindo um Firebase
    // Requer regras de seguran�a especificas no firebase

    OtsFirebase.API(edtApiKey.Text, edtProjectId.Text);

    case ComboFiltro.ItemIndex of
      0: //startAt
        memoResp.Text := OtsFirebase
                          .Auth(edtEmail.Text, edtPassword.Text)
                          .Database.Resource([edtNode.Text])
                          .filterBy(edtKey.Text)
                          .startAt(edtKeyValue.Text)
                          .timeOut()
                          .Get();

      1: //equalTo
        memoResp.Text := OtsFirebase
                          .Auth(edtEmail.Text, edtPassword.Text)
                          .Database.Resource([edtNode.Text])
                          .filterBy(edtKey.Text)
                          .equalTo(edtKeyValue.Text)
                          .timeOut()
                          .Get();
    end;

  end;

  Time2 := Now - Time1;

  lbResp.Caption := 'Resposta em: ' + FormatDateTime('hh:mm:ss:zzz', Time2);
end;

procedure TfrmMain.btnExecuteOuterClick(Sender: TObject);
var
  Time1, Time2: TTime;
begin
  Time1 := Now;

  memoResp.Text := OtsFirebase.Request(edtUrlRequest.Text, memoToken.Text)
                      .Get();

  Time2 := Now - Time1;

  lbResp.Caption := 'Resposta em: ' + FormatDateTime('hh:mm:ss:zzz', Time2);
end;

end.
