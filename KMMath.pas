unit KMMath;

interface

uses
  System.SysUtils;

function Min(Values: array of Integer): Integer;
function Max(Values: array of Integer): Integer;

implementation

function Min(Values: array of Integer): Integer;
var
  i: Integer;
begin
  if Length(Values) < 1 then
    raise Exception.Create('Min() with no values');

  Result := Values[0];

  for i in Values do
    if Result > i then
      Result := i;
end;

function Max(Values: array of Integer): Integer;
var
  i: Integer;
begin
  if Length(Values) < 1 then
    raise Exception.Create('Max() with no values');

  Result := Values[0];

  for i in Values do
    if Result < i then
      Result := i;
end;

end.
