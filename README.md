# Dlang hunspell wrapper

Wrapper for [hunspell](https://hunspell.github.io/) speller

# Dependences

```
sudo apt install hunspell hunspell-dev
```
Optionality:
```
sudo apt hunspell-ru hunspell-de hunspell-fr
```

# Usage

## Check word

```d
void main()
{
    auto spell = Spell.makeDefault();

    writeln("колбаса : ", spell.check("колбаса"));
    writeln("калбаса : ", spell.check("калбаса"));
    writeln("жир     : ", spell.check("жир"));
    writeln("жыр     : ", spell.check("жыр"));
}
```
output:
```
колбаса : true
калбаса : false
жир     : true
жыр     : false
```

## Get dictionary encoding

```d
writeln(spell.dicEncoding());
```
output:
```
UTF-8
```

## Get suggestions

```d
auto suggestions = spell.suggest("калбаса");
for(size_t i = 0; i < suggestions.size; ++i) {
    suggestions[i].writeln();
}
```
output:
```
колбаса
карбаса
кал баса
колбаска
```
Or the same:
```d
foreach(ref w; suggestions.range) {
    w.writeln();
}
```
or
```d
foreach(ref w; suggestions.toStrings) {
    w.writeln();
}
```

Method `Slice.toStrings()` returns strings array `string[]`

# Analyze

```d
auto analyze = spell.analyze("колбаса");
foreach(w; analyze.range) {
    w.writeln();
}
```
output:
```
st:колбаса
```
# Stemming

```d
foreach(w; spell.stem("колбаса").toStrings) {
    w.writeln();
}
```
output:
```
колбаса
```


---
Because **Hunspell** released under *GNU LGPL v3* **dhunspell** has the same lecense.

[The GNU LGPL v3 License](LICENSE)
