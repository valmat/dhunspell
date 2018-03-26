module dhunspell.hunspell;


private extern (C) {
nothrow:
    
    struct Hunhandle {};


    Hunhandle* Hunspell_create(const char * affpath, const char * dpath);
    void Hunspell_destroy(Hunhandle* pHunspell);

    // spell(word) - spellcheck word
    // output: 0 = bad word, not 0 = good word
    int Hunspell_spell(const Hunhandle* pHunspell, const char * word);

    char* Hunspell_get_dic_encoding(const Hunhandle* pHunspell);

    /* load extra dictionaries (only dic files)
     * output: 0 = additional dictionary slots available, 1 = slots are now full*/
    int Hunspell_add_dic(Hunhandle* pHunspell, const char* dpath);

    //  suggest(suggestions, word) - search suggestions
    //  input: pointer to an array of strings pointer and the (bad) word
    //    array of strings pointer (here *slst) may not be initialized
    //  output: number of suggestions in string array, and suggestions in
    //    a newly allocated array of strings (*slts will be NULL when number
    //    of suggestion equals 0.)
    // 
    int Hunspell_suggest(const Hunhandle* pHunspell, char*** slst, const char * word);

    //
    // morphological functions
    //

    // analyze(result, word) - morphological analysis of the word
    int Hunspell_analyze(const Hunhandle* pHunspell, char*** slst, const char * word);

    // stem(result, word) - stemmer function
    int Hunspell_stem(const Hunhandle* pHunspell, char*** slst, const char * word);

    // stem(result, analysis, n) - get stems from a morph. analysis
    // example:
    // char ** result, result2;
    // int n1 = Hunspell_analyze(result, "words");
    // int n2 = Hunspell_stem2(result2, result, n1);   
    int Hunspell_stem2(const Hunhandle* pHunspell, char*** slst, char** desc, int n);

    // generate(result, word, word2) - morphological generation by example(s)
    int Hunspell_generate(const Hunhandle* pHunspell, char*** slst, const char * word, const char * word2);

    // generate(result, word, desc, n) - generation by morph. description(s)
    // example:
    // char ** result;
    // char * affix = "is:plural"; // description depends from dictionaries, too
    // int n = Hunspell_generate2(result, "word", &affix, 1);
    // for (int i = 0; i < n; i++) printf("%s\n", result[i]);
    int Hunspell_generate2(const Hunhandle* pHunspell, char*** slst, const char * word, char** desc, int n);

    //
    // functions for run-time modification of the dictionary
    //

    // add word to the run-time dictionary
    //int Hunspell_add(Hunhandle* pHunspell, const char * word);

    // add word to the run-time dictionary with affix flags of
    // the example (a dictionary word): Hunspell will recognize
    // affixed forms of the new word, too.
    //int Hunspell_add_with_affix(Hunhandle* pHunspell, const char * word, const char * example);

    // remove word from the run-time dictionary
    //int Hunspell_remove(Hunhandle* pHunspell, const char * word);

    //
    // free suggestion lists
    //
    void Hunspell_free_list(const Hunhandle* pHunspell, char *** slst, int n);
}

import dhunspell.slice;

alias str2cstr = Slice.str2cstr;

//import std.stdio : writeln;

struct HunspellStringList
{
nothrow:
private:
    // Only Spell can create HunspellStringList
    this(const Hunhandle* pHunspell, char** slst, size_t size)
    {
        _handle = pHunspell;
        _slst   = slst;
        _size   = size;
    }
public:

    ~this()
    {
        Hunspell_free_list(_handle, &_slst, cast(int) _size);
    }

    size_t size() const
    {
        return _size;
    }
    size_t length() const
    {
        return _size;
    }

    // get Itarable
    HunspellStringListRange range()
    {
        return HunspellStringListRange(_slst, _size);
    }
    HunspellStringListRange range() const
    {
        return HunspellStringListRange(_slst, _size);
    }

    string[] toStrings() const
    {
        //import std.array : array;
        //import std.algorithm : map;
        string[] rez;
        rez.reserve(_size);
        //rez = this.range.map!(x => x.toString()).array;
        foreach(ref w; this.range) {
            rez ~= w.toString.idup;
        }
        return rez;
    }

    Slice opIndex(size_t i)
    {
        return Slice(_slst[i]);
    }

private:
    const Hunhandle* _handle;
    char** _slst;
    size_t _size;
};

// Range for HunspellStringList
private struct HunspellStringListRange
{
nothrow:
    this(const char** slst, const size_t size)
    {
        _begin  = cast(char**) slst;
        _end    = slst + size;
    }

    @property bool empty() const
    {return _begin == _end;}
    @property Slice front()
    {
        return Slice(*_begin);
    }
    void popFront() {++_begin;}

private:
    char** _begin;
    const char** _end;
}


struct Spell
{
nothrow:
    this(string aff_path, string dic_path)
    {
        _handle = Hunspell_create(aff_path.str2cstr, dic_path.str2cstr);

    }
    static Spell makeDefault()
    {
        return Spell("/usr/share/hunspell/ru_RU.aff", "/usr/share/hunspell/ru_RU.dic");
    }

    ~this()
    {
        Hunspell_destroy(_handle);
    }

    // Check if word is correct
    bool check(string word) const
    {
        //return Hunspell_spell(_handle, const char * word);
        return 1 == Hunspell_spell(_handle, word.str2cstr);
    }

    Slice dicEncoding() const
    {
        //char* Hunspell_get_dic_encoding(_handle);
        return Slice(Hunspell_get_dic_encoding(_handle));
    }


    // load extra dictionaries (only dic files)
    // output: false  additional dictionary slots available, true = slots are now full
    bool addDic(string dic_path)
    {
        return 1 == Hunspell_add_dic(_handle, dic_path.str2cstr);
    }


    //  suggest(suggestions, word) - search suggestions
    //  input: pointer to an array of strings pointer and the (bad) word
    //    array of strings pointer (here *slst) may not be initialized
    //  output: number of suggestions in string array, and suggestions in
    //    a newly allocated array of strings (*slts will be NULL when number
    //    of suggestion equals 0.)
    // 
    //int Hunspell_suggest(_handle, char*** slst, const char * word);
    HunspellStringList suggest(string word) const
    {
        char **wlst;
        size_t size = Hunspell_suggest(_handle, &wlst, word.str2cstr);
        return HunspellStringList(_handle, wlst, size);
    }


    //
    // morphological functions
    //

    // analyze(result, word) - morphological analysis of the word
    //int Hunspell_analyze(_handle, char*** slst, const char * word);
    HunspellStringList analyze(string word) const
    {
        char **wlst;
        size_t size = Hunspell_analyze(_handle, &wlst, word.str2cstr);
        return HunspellStringList(_handle, wlst, size);
    }


    // stem(result, word) - stemmer function
    //int Hunspell_stem(_handle, char*** slst, const char * word);
    HunspellStringList stem(string word) const
    {
        char **wlst;
        size_t size = Hunspell_stem(_handle, &wlst, word.str2cstr);
        return HunspellStringList(_handle, wlst, size);
    }


    // stem(result, analysis, n) - get stems from a morph. analysis
    // example:
    // char ** result, result2;
    // int n1 = Hunspell_analyze(result, "words");
    // int n2 = Hunspell_stem2(result2, result, n1);   
    //int Hunspell_stem2(_handle, char*** slst, char** desc, int n);
    //-//HunspellStringList stem2(string word) const
    //-//int Hunspell_stem2(_handle, char*** slst, char** desc, int n);
    //-//{
    //-//    char **wlst;
    //-//    size_t size = Hunspell_stem2(_handle, &wlst, word);
    //-//    return HunspellStringList(wlst, size);
    //-//}


    // generate(result, word, word2) - morphological generation by example(s)
    //int Hunspell_generate(_handle, char*** slst, const char * word, const char * word2);
    //-//HunspellStringList generate(string word) const
    //-//int Hunspell_generate(_handle, char*** slst, const char * word, const char * word2);
    //-//{
    //-//    char **wlst;
    //-//    size_t size = Hunspell_generate(_handle, &wlst, word);
    //-//    return HunspellStringList(wlst, size);
    //-//}


    // generate(result, word, desc, n) - generation by morph. description(s)
    // example:
    // char ** result;
    // char * affix = "is:plural"; // description depends from dictionaries, too
    // int n = Hunspell_generate2(result, "word", &affix, 1);
    // for (int i = 0; i < n; i++) printf("%s\n", result[i]);
    //int Hunspell_generate2(_handle, char*** slst, const char * word, char** desc, int n);
    //-//HunspellStringList generate2(string word) const
    //-//int Hunspell_generate2(_handle, char*** slst, const char * word, char** desc, int n);
    //-//{
    //-//    char **wlst;
    //-//    size_t size = Hunspell_generate2(_handle, &wlst, word);
    //-//    return HunspellStringList(wlst, size);
    //-//}

private:
    Hunhandle* _handle;
}


// to run tests: dmd -unittest -main  dhunspell/tie.d && ./dhunspell/tie
// or: cd source 
// rdmd -unittest -main -L-lstdc++ -L-lhunspell dhunspell/hunspell
nothrow unittest {
    auto spell = Spell("/usr/share/hunspell/ru_RU.aff", "/usr/share/hunspell/ru_RU.dic");

    assert( spell.check("колбаса") );
    assert(!spell.check("калбаса") );
    assert( spell.check("жир")     );
    assert(!spell.check("жыр")     );

    assert("UTF-8" == spell.dicEncoding().toString);

    
    auto suggestions = spell.suggest("калбаса");
    auto sug_arr = ["колбаса", "карбаса", "кал баса", "колбаска"];

    import std.array : array;
    import std.algorithm : map;
    assert(suggestions.range.map!"a.toString".array == sug_arr);
    assert(suggestions.toStrings == sug_arr);

    assert(spell.analyze("колбаса").toStrings == [" st:колбаса"]);
    assert(spell.stem("колбаса").toStrings    == ["колбаса"]);
}

nothrow unittest {
    auto spell = Spell("/usr/share/hunspell/ru_RU.aff", "/usr/share/hunspell/ru_RU.dic");
    spell.addDic("/usr/share/hunspell/en_US.dic");

    assert( spell.check("rabbit") );
    assert(!spell.check("rebbit") );
    assert( spell.check("you")    );
    assert(!spell.check("yuo")    );


    assert(spell.suggest("raabbit").toStrings == ["rabbit", "rabbi", "Rabbi"]);
    assert(spell.suggest("yuo").toStrings     == ["you", "yup", "yo"]);
}