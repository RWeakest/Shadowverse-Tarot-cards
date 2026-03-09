local cols = shadowverse_tarot_cards.Collectibles

local Collectibles = {}    
local function AddItem(id, entry)
    if (id) then
        Collectibles[id] = entry;
    end
end

AddItem(cols.Governing_Justice.ID, {
    Name = "Governing Justice",
    Description = 
    "#30% chance to spawn an extra {{Card9}} Justice card upon clearing a room"..
    "#Gain 0.8 seconds of invincibility when picking up a {{Heart}} Heart, {{Coin}} Coin, {{Key}} Key, or {{Bomb}} Bomb"..    
    "#{{ArrowUp}} Upon entering the next floor, converts the total value of uncollected pickups from the previous floor into a {{DamageSmall}} Damage up"
})

AddItem(cols.Raging_Chariot.ID, {
    Name = "Raging Chariot",
    Description = 
    "#30% chance to spawn an extra {{Card8}} The Chariot card upon clearing a room"..
    "#Upon contact with an enemy, 77% chance to deal 77 damage to all enemies in the room and heal 1 Red Heart"..
    "#{{Warning}} Otherwise, you take 2 hearts of damage"
})

AddItem(cols.Filling_Temperance.ID, {
    Name = "Filling Temperance",
    Description = 
    "#30% chance to spawn an extra {{Card15}} Temperance card upon clearing a room"..
    "#Upon entering a new room, destroys one enemy for each empty Heart Container you have (Deals 30 damage to bosses instead)"
})

AddItem(cols.Filling_Lovers.ID, {
    Name = "Filling Lovers",
    Description = 
    "#30% chance to spawn an extra {{Card7}} The Lovers card upon clearing a room"..
    "#Upgrades {{Heart}} Hearts when they spawn"
})

AddItem(cols.Wandering_Fool.ID, {
    Name = "Wandering Fool",
    Description = 
    "#30% chance to spawn an extra {{Card1}} The Fool card upon clearing a room"..
    "#When a teleport effect is triggered, permanently reduces the maximum health of all enemies by 1"
})

AddItem(cols.Revolving_Wheel_of_Fortune.ID, {
    Name = "Revolving Wheel of Fortune",
    Description = 
    "#30% chance to spawn an extra {{Card11}} Wheel of Fortune card upon clearing a room"..
    "#When losing coins, randomly spawns a pickup or grants a stat boost"
})

AddItem(cols.Inspiring_Strength.ID, {
    Name = "Inspiring Strength",
    Description = 
    "#30% chance to spawn an extra {{Card12}} Strength card upon clearing a room"..
    "#The first time a stat is increased in a room, gain an additional 10% boost to that stat"
})

AddItem(cols.Skybound_Hanged_Man.ID, {
    Name = "Skybound Hanged Man",
    Description = 
    "#30% chance to spawn an extra {{Card13}} The Hanged Man card upon clearing a room"..
    "#While flying or entering a room while flying, causes items to spawn from a random item pool"..
    "#Gain +0.15 {{DamageSmall}} Damage up for each different item pool among your currently held items"
})


local lang = "en_us";
local descriptions = EID.descriptions[lang];
for id, col in pairs(Collectibles) do
    EID:addCollectible(id, col.Description, col.Name, lang);
end