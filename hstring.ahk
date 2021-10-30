; Wraps a HSTRING.  Takes ownership of the handle it is given.
class HString {
	__new(hstr := 0) => this.ptr := hstr
	ToString() => WindowsGetString(this)
	__delete() => DllCall("combase.dll\WindowsDeleteString", "ptr", this)
}

; Create HString for passing to ComCall/DllCall.  Has automatic cleanup.
HStringFromString(str) => HString(WindowsCreateString(str))

; Delete a HString and return the equivalent string value.
HStringRet(hstr) { ; => String(HString(hstr))
	s := DllCall("combase.dll\WindowsGetStringRawBuffer", "ptr", hstr, "uint*", &len:=0, "ptr")
	s := StrGet(s, -len, "UTF-16")
    DllCall("combase.dll\WindowsDeleteString", "ptr", hstr)
    return s
}

; Create a raw HSTRING and return the handle.
WindowsCreateString(str, len := unset) {
    DllCall("combase.dll\WindowsCreateString"
			, "ptr", StrPtr(str), "uint", IsSet(len) ? len : StrLen(str)
            , "ptr*", &hstr := 0, "hresult")
    return hstr
}

; Get the string value of a HSTRING.
WindowsGetString(hstr, &len := 0) {
	p := DllCall("combase.dll\WindowsGetStringRawBuffer"
		, "ptr", hstr, "uint*", &len := 0, "ptr")
	return StrGet(p, -len, "UTF-16")
}

; Delete a HSTRING.
WindowsDeleteString(hstr) {
    ; api-ms-win-core-winrt-string-l1-1-0.dll
    ; hstr or hstr.ptr can be 0 (equivalent to "").
    DllCall("combase.dll\WindowsDeleteString", "ptr", hstr)
}