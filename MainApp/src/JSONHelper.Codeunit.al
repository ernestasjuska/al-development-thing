codeunit 50101 "ALDT JSON Helper"
{
    Access = Internal;

    internal procedure GetToken(ObjectToken: JsonToken; PropertyName: Text) Token: JsonToken
    begin
        ObjectToken.AsObject().Get(PropertyName, Token);
    end;

    internal procedure GetToken(Object: JsonObject; PropertyName: Text) Token: JsonToken
    begin
        Object.Get(PropertyName, Token);
    end;

    internal procedure GetText(ObjectToken: JsonToken; PropertyName: Text): Text
    begin
        exit(GetToken(ObjectToken, PropertyName).AsValue().AsText());
    end;

    internal procedure GetText(Object: JsonObject; PropertyName: Text): Text
    begin
        exit(GetToken(Object, PropertyName).AsValue().AsText());
    end;

    internal procedure GetInteger(ObjectToken: JsonToken; PropertyName: Text): Integer
    begin
        exit(GetToken(ObjectToken, PropertyName).AsValue().AsInteger());
    end;

    internal procedure GetInteger(Object: JsonObject; PropertyName: Text): Integer
    begin
        exit(GetToken(Object, PropertyName).AsValue().AsInteger());
    end;

    internal procedure GetBoolean(ObjectToken: JsonToken; PropertyName: Text): Boolean
    begin
        exit(GetToken(ObjectToken, PropertyName).AsValue().AsBoolean());
    end;

    internal procedure GetBoolean(Object: JsonObject; PropertyName: Text): Boolean
    begin
        exit(GetToken(Object, PropertyName).AsValue().AsBoolean());
    end;
}