//
// Rae c string wrapper
//
module dhunspell.slice;

import std.conv         : to;
import core.stdc.string : strlen;
struct Slice
{
nothrow:
    static const(char*) str2cstr(string rhs)
    {
        // make null terminated const char
        char[] str;
        str.length  = rhs.length+1;
        str[0..$-1] = rhs[0..$];
        str[$-1]    ='\0';
        return &str.to!(const(char)[])[0];
    }

    this(string rhs)
    {
        _ptr = &rhs.to!(immutable(char)[])[0];
        _len = rhs.length;
    }
    this(const char * rhs)
    {
        _ptr = cast(immutable(char*)) rhs;
        _len = rhs.strlen;
    }

    size_t size() const
    {
        return _len;
    }

    char[] value()
    {
        return cast(char[])(_ptr[0.._len]);
    }

    string toString()
    {
        return (_ptr[0.._len]).to!string;
    }
private:
    
    immutable char* _ptr;
    size_t _len;
}
