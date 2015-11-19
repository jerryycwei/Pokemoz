SRCS = Gui.oz  Config.oz Trainer.oz Utils.oz Pokemoz.oz
OBJS = $(SRCS:.oz=.ozf)
MAIN = POKEMOZ_GAME.oz
EXECUTABLE = POKEMOZ_GAME

.PHONY: clean

$(EXECUTABLE): $(OBJS) $(MAIN)
	ozc -c $(MAIN)
	ozengine POKEMOZ_GAME.ozf 15

Gui.ozf: Gui.oz Config.oz Trainer.oz Utils.oz Pokemoz.oz
	ozc -c Gui.oz -o Gui.ozf
	
Config.ozf : Config.oz Gui.oz
	ozc -c Config.oz -o Config.ozf
	
Trainer.ozf : Trainer.oz Pokemoz.oz
	ozc -c Trainer.oz -o Trainer.ozf
	
Utils.ozf : Utils.oz
	ozc -c Utils.oz -o Utils.ozf
	
Pokemoz.ozf : Pokemoz.oz
	ozc -c Pokemoz.oz -o Pokemoz.ozf

all: $(EXECUTABLE)

clean:
	rm -f $(OBJS) $(EXECUTABLE)
