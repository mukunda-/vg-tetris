
from subprocess import call

print "generating block cell images..."

for x in range(0,256):
	print "pooping... blockcell-%03d.png" % x
	call( ["copy", "blockcell.png", "blockcell\\blockcell-%03d.png" % x], shell=True )
	
	for bit in range(0,8):
		if( not(x & (1<<bit)) ): continue
		bx = bit % 2
		by = bit // 2
		call( ["composite", "block.png", "-geometry", "+%d+%d" % (bx*8,by*8), "blockcell\\blockcell-%03d.png"%x, "blockcell\\blockcell-%03d.png"%x], shell=True )
		
	

	