polyline = {color="blue", thickness=2, npoints=4,

              {x=0,   y=0},

              {x=-10, y=0},

              {x=-10, y=1},

              {x=0,   y=1}

}

print(string.format('polyline.color = %s, polyline.thickness = %d, polyline.npoints = %d', 
polyline.color, polyline.thickness, polyline.npoints))

print(string.format('polyline[1].x = %d, polyline[1].y = %d', polyline[1].x, polyline[1].y))
print(string.format('polyline[2].x = %d, polyline[2].y = %d', polyline[2].x, polyline[2].y))
print(string.format('polyline[3].x = %d, polyline[3].y = %d', polyline[3].x, polyline[3].y))
print(string.format('polyline[4].x = %d, polyline[4].y = %d', polyline[4].x, polyline[4].y))