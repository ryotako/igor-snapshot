# igor-snapshot

### Usage
![](http://img.f.hatena.ne.jp/images/fotolife/r/ryotako/20160806/20160806015513.gif)

### Options
When you want to customize the behavior, write as below on your main procedure window. You don't have to rewrite snapshot.ipf. 

```igorpro
override constant    Snapshot_Resolution = 2 // 4 is default value of Igor Pro  
override constant    Snapshot_ColorPrint = 1 // 0 means RGB and the others means CMYK
override strconstant Snapshot_Menu = "Graph;-;(Snapshot" // Menu title  
override strconstant Snapshot_DefaultFormat = "pdf" // pdf, tiff, jpeg, png, pict, or eps
override strconstant Snapshot_DefaultHook = "Save" // Save, Quit, or Save;Quit
```
