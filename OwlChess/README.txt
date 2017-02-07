
OWL CHESS is a 32 bit chess engine written in Borland Turbo C (year 1992-95).
A very well documented old source code was available on internet, google it.
It is very readable and portable.

Ports
======

At first, a javascript port:
http://chessforeva.appspot.com/C0_OwlChess.htm 

The AS3 port derived from this.

Flash is too underrated platform. Critics say it is too much resources
consuming installable. Anyways, it is really good working virtual machine
with development tools and documentation. Perfect for small graphics games.


Notes on the project
=====================

AS3 code gives very small swf-result.
All the graphics is a bitmap big as screen.
Drawings are made directly in the memory array.
Bitmaps are converted to arrays of constants.
No embedded files.
Chess book (32Kb) also is an array.
Lua (JIT) scripts prepare bmp and book files.

Mouse, no keyboard.



User options
==============

Scaling is 1 (if too small screen available) or 2 (actually, always).
User can set search depth (ply) for AI, adjust time in seconds to think.
Selfgame is AI vs AI playing demo.
Promoted piece is always a Queen, no knight promotion available, sorry.
Ignores repetitions or draws, simply end the playing.


Chessforeva, feb.2017
http://chessforeva.blogspot.com/2017/02/flash-owlchess.html

