#using scripts\shared\callbacks_shared;
#using scripts\shared\util_shared;

/*
#####################
by: M.A.K.E C E N T S
#####################
Script:

taf::init(  );

#using scripts\zm\TempArnieFix;

scriptparsetree,scripts/zm/TempArnieFix.gsc

###############################################################################
*/
#namespace taf;
function init(){
	callback::on_spawned(&TempFixArnie);
}
function WatchPlayerGuns(){
	while(1){
		self util::waittill_any("weapon_fired", "weapon_change_complete");
		self.weaps = self GetWeaponsListPrimaries();
		self.ammostock = [];
		self.ammoclip = [];
		foreach(weapon in self.weaps){
			self.ammostock[weapon] = self GetWeaponAmmoStock(weapon);
			self.ammoclip[weapon] = self GetWeaponAmmoClip(weapon);
		}
	}
}
function TempFixArnie(){
	self thread WatchPlayerGuns();
	haveArnie = false;
	while(1){
		self waittill("weapon_change");
		foreach(weapon in self.weaps){
			if(!(self HasWeapon(weapon))){
				lostweapon = weapon;
				break;				
			}
		}
		if(self HasWeapon(getweapon("octobomb"))) haveArnie = true;
		if(self HasWeapon(getweapon("octobomb_upgraded"))) haveArnie = true;
		if(IsSubStr(self GetCurrentWeapon().rootweapon.name, "octobomb")) haveArnie = true;
		if(!haveArnie) continue;
		if(isdefined(lostweapon)){
			self GiveWeapon(lostweapon);
			self SetWeaponAmmoClip(weapon, self.ammoclip[weapon]);
			self SetWeaponAmmoStock(weapon, self.ammostock[weapon]);
		}
		break;
	}
}