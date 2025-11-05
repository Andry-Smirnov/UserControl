{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pckUserControlDesign;

{$warn 5023 off : no warning about unused units}
interface

uses
  uc_about, uc_settingseditor, uc_idle, uc_reg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uc_reg', @uc_reg.Register);
end;

initialization
  RegisterPackage('pckUserControlDesign', @Register);
end.
