{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pckUserControlRuntime;

{$warn 5023 off : no warning about unused units}
interface

uses
  ChangeUserPassword, UCBase, passwords, EnvMsgForm_U, MsgRecForm_U, 
  MsgsForm_U, UCDataInfo, UCMessages, UserPermis_U, settings, loginwindow, 
  UcConsts_Language, pUCGeral, userframe, pUCFrame_Profile, pUCFrame_Log, 
  pUcFrame_UserLogged, UCMail, UCEMailForm_U, IncUser_U, IncPerfil_U, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('pckUserControlRuntime', @Register);
end.
