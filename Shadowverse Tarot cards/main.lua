shadowverse_tarot_cards= RegisterMod("Shadowverse_Tarot_cards", 1)

local save = require("scripts.save")
save.Init(shadowverse_tarot_cards)

include("scripts/enums")

if EID then

	include("eid/cn/collectibles");
	include("eid/en/collectibles");

end