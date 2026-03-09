local cols = shadowverse_tarot_cards.Collectibles

local Collectibles = {}	
local function AddItem(id, entry)
	if (id) then
		Collectibles[id] = entry;
	end
end

AddItem(cols.Governing_Justice.ID, {
	Name = "约束的《正义》",
    Description = 
	"#清理房间时,有30%的概率额外生成一张{{Card9}}正义"..
	"#拾取{{Heart}}心,{{Coin}}钱币,{{Key}}钥匙或{{Bomb}}炸弹时,获得0.8秒无敌"..	
	"#{{ArrowUp}} 进入下一楼层时,将上一层未拾取掉落物的总价值转化{{DamageSmall}}伤害修正"
})

AddItem(cols.Raging_Chariot.ID, {
	Name = "威猛的《战车》",
    Description = 
	"#清理房间时,有30%的概率额外生成一张{{Card8}}战车"..
	"#与敌人接触时,77%概率对房间内所有敌人造成77点伤害,同时恢复1颗红心"..
	"#{{Warning}} 否则,对玩家造成2心伤害"
})

AddItem(cols.Filling_Temperance.ID, {
	Name = "充实的《节制》",
    Description = 
	"#清理房间时,有30%的概率额外生成一张{{Card15}}节制"..
	"#进入新房间时,每有一个空心之容器就破坏一个敌人(对头目改为造成30点伤害)"
})

AddItem(cols.Filling_Lovers.ID, {
	Name = "充实的《恋人》",
    Description = 
	"#清理房间时,有30%的概率额外生成一张{{Card7}}恋人"..
	"#生成{{Heart}}心时，将其升级"
})

AddItem(cols.Wandering_Fool.ID, {
	Name = "漫步的《愚者》",
    Description = 
	"#清理房间时,有30%的概率额外生成一张{{Card1}}愚者"..
	"#触发传送效果时，永久为所有敌人削减一点生命上限"
})

AddItem(cols.Revolving_Wheel_of_Fortune.ID, {
	Name = "转动的《命运之轮》",
    Description = 
	"#清理房间时,有30%的概率额外生成一张{{Card11}}命运之轮"..
	"#失去硬币时,随机生成掉落物或获得属性增益"
})

AddItem(cols.Inspiring_Strength.ID, {
	Name = "思念的《力量》",
    Description = 
	"#清理房间时,有30%的概率额外生成一张{{Card12}}力量"..
	"#在一个房间内首次获得属性值提升时,额外获得10%提升"
})

AddItem(cols.Skybound_Hanged_Man.ID, {
	Name = "脚踩天穹的《倒吊人》",
    Description = 
	"#清理房间时,有30%的概率额外生成一张{{Card13}}倒吊人"..
	"#玩家处于飞行状态或以飞行状态进入房间时,使道具从随机道具池中生成"..
	"#玩家所持有道具中每有一个道具池,就获得{{DamageSmall}}伤害修正+0.15"
})


local lang = "zh_cn";
local descriptions = EID.descriptions[lang];
for id, col in pairs(Collectibles) do
	EID:addCollectible(id, col.Description, col.Name, lang);
end