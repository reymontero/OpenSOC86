testroms := $(patsubst %.s,%.out,$(wildcard *.s))
testhex := $(patsubst %.s,%.hex,$(wildcard *.s))

all: $(testroms)

allhex: $(testhex)

%.hex: %.out
	od -An -t x1 -v $< > $@

%.out: %.o
	objcopy -O binary -S $< $@

%.o: %.s
	as $< -o $@

clean:
	rm -f *.o *.out *.hex
