.TL
This is a title
.AU
John Doe
.AI
University of West Bumblefuzz
.AB no
This is an abstract.
.PP
A multi-paragraph abstract.
.AE
.NH
Numbered header of level 1
.PP
This is a paragraph.
.NH 2
Numbered header of level 2
.PP
This is more paragraph.
.B "This is a bold setence."
.I "This is an italic sentence."
.UL "underline text"
.BX "boxed text"
.RS
.PP
This is an indented paragraph.
.RE
.IP \(bu 2
This is a list item.
.IP \(bu 2
Here is another
.IP \(bu 2
And another
.PP
Now we're gonna define a macro.
.de BL
.IP \(bu 2
..
.BL
This is a bulleted item
.NH
Maths
.EQ
define disc `b sup {2} - 4ac`
.EN
.EQ
x != 3 +- 5
.EN
.EQ
phi = {1 + sqrt 5} over 2
.EN
.EQ
s = sqrt {{sum from i=1 to N {(x sub i - x bar ) sup 2}} over {N - 1}}
.EN
.EQ
pi = int from -1 to 1 {dx over {sqrt {1 - x sup 2}}}
.EN
.EQ
x = {-b +- sqrt { disc }} over {2a}
.delim $$
.EN
.PP
This is a paragraph.
Here is another sentence with $disc$.
