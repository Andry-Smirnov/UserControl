{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pckUserControlRuntime;

{$warn 5023 off : no warning about unused units}
interface

uses
  uc_base, uc_changeuserpassword, uc_password, uc_newmessage, 
  uc_receivedmessage, uc_systemmessage, uc_messages, uc_userpermissions, 
  uc_loginwindow, uc_language, uc_tools, uc_userframe, uc_profileframe, 
  uc_logframe, uc_frameuserslogged, uc_mail, uc_emailsending, uc_adduser, 
  uc_addprofile, uc_settings, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uc_base', @uc_base.Register);
end;

initialization
  RegisterPackage('pckUserControlRuntime', @Register);
end.
