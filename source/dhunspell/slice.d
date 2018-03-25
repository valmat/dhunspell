module dhunspell.slice;

import std.conv         : to;
import core.stdc.string : strlen;

struct Slice {
    static const(char*) str2cstr(string rhs)
    {
        return &rhs.to!(immutable(char)[])[0];
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
