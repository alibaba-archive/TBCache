# README(Chinese)

## TBCache是什么
![License](https://img.shields.io/badge/license-MIT-blue.svg)


TBCache 是 Teambition iOS 研发团队封装的一款缓存库，参考了[TMCache](https://github.com/tumblr/TMCache)并使用了其中的一些代码。:)

## TBCache提供了哪些功能

TBCache 提供了对遵循`<NSCoding>`协议的对象进行缓存的功能。

同时，TBCache提供了两种缓存策略，一种是存在内存里，一种是存在磁盘上。只需要使用`TBCache`这个单例类来进行对象的缓存，当程序进入后台或者是收到`MemoryWarning`的时候，会把内存中的缓存全部移到磁盘上，不需要使用者操心。

## TBCache适用的版本

适用于iOS 5.0及之后的版本。

## TBCache相比于TMCache的优点

存储更快，更优的缓存策略。

同时由于TMCache已经不再更新，本项目会持续更新。:)

## 相关的使用教程和Demo

暂无

## 作者

TBCache 的主要作者是：

 - [StormXX](https://github.com/StormXX)
 
## 感谢

TBCache 起源于[TMCache](https://github.com/tumblr/TMCache)，从中借鉴了它的代码思想，也使用了部分源代码，在此对[TMCache](https://github.com/tumblr/TMCache)表示感谢。:)

## 协议

TBCache 被许可在 MIT 协议下使用。查阅 LICENSE 文件来获得更多信息