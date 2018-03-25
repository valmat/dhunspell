#!/usr/bin/rdmd --shebang=-L-lstdc++ -L-lhunspell -I../source -I.

import std.stdio : writeln;
import dhunspell : Spell;

void main()
{
    //auto spell = Spell("/usr/share/hunspell/ru_RU.aff", "/usr/share/hunspell/ru_RU.dic");
    auto spell = Spell.makeDefault();

    writeln("колбаса : ", spell.check("колбаса"));
    writeln("калбаса : ", spell.check("калбаса"));
    writeln("жир     : ", spell.check("жир"));
    writeln("жыр     : ", spell.check("жыр"));

    
    writeln(spell.dicEncoding());

    auto suggestions = spell.suggest("калбаса");

    writeln("~~~~~~~~~~~~~~~~~~~");
    for(size_t i = 0; i < suggestions.size; ++i) {
        suggestions[i].writeln();
    }

    writeln("~~~~~~~~~~~~~~~~~~~");
    foreach(ref w; suggestions.range) {
        w.writeln();
    }
    writeln("~~~~~~~~~~~~~~~~~~~");
    foreach(ref w; suggestions.range) {
        w.writeln();
    }
    writeln("~~~~~~~~~~~~~~~~~~~");
    writeln(suggestions.toStrings);

    writeln("~~~~~~~~~~~~~~~~~~~");
    writeln("~~~~~~~~~~~~~~~~~~~");



    writeln("~~~~~~~~~ analyze ~~~~~~~~~~");
    auto analyze = spell.analyze("колбаса");
    foreach(w; analyze.range) {
        w.writeln();
    }
    writeln(analyze.toStrings);

    writeln("~~~~~~~~~ stem ~~~~~~~~~~");
    writeln(spell.stem("колбаса").toStrings);

}