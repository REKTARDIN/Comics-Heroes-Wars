LinkLuaModifier ("modifier_item_ice_pearl", "items/item_ice_pearl.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_ice_pearl_reduction", "items/item_ice_pearl.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_ice_pearl_active", "items/item_ice_pearl.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_ice_pearl_cooldown", "items/item_ice_pearl.lua", LUA_MODIFIER_MOTION_NONE)

item_ice_pearl = class({})

function item_ice_pearl:GetIntrinsicModifierName() return "modifier_item_ice_pearl" end

function item_ice_pearl:OnSpellStart()
    if IsServer() then
        EmitSoundOn("Item.GuardianGreaves.Target", self:GetCaster())
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_ice_pearl_active", {duration = self:GetSpecialValueFor("active_duration")})
    end
end

modifier_item_ice_pearl = class({})

function modifier_item_ice_pearl:IsHidden() return true end
function modifier_item_ice_pearl:IsPurgable() return false end

function modifier_item_ice_pearl:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_item_ice_pearl:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor ("bonus_damage") end
function modifier_item_ice_pearl:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor ("bonus_armor") end
function modifier_item_ice_pearl:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end

function modifier_item_ice_pearl:OnTakeDamage(params)
  if IsServer() then
    if params.unit == self:GetParent() and self:GetParent():HasModifier("modifier_item_ice_pearl_cooldown") == false and params.attacker ~= self:GetParent() and params.attacker:IsBuilding() == false and params.attacker:IsRealHero() and self:GetParent():IsRealHero() then

      params.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_ice_pearl_reduction", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
      EmitSoundOn("Hero_Winter_Wyvern.WintersCurse.Cast", params.attacker)
      EmitSoundOn("Hero_Winter_Wyvern.ColdEmbrace.Cast", params.attacker)

      ApplyDamage({
          victim = params.attacker,
          attacker = self:GetParent(),
          damage = params.damage * self:GetAbility():GetSpecialValueFor("damage_return") / 100,
          damage_type = params.damage_type,
          ability = self:GetAbility(),
          damage_flags = params.damage_flags
      })

      self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_ice_pearl_cooldown", {duration = self:GetAbility():GetCooldown(self:GetAbility():GetLevel())})
    end
  end
end

modifier_item_ice_pearl_reduction = class({})

function modifier_item_ice_pearl_reduction:IsDebuff() return true end
function modifier_item_ice_pearl_reduction:DeclareFunctions()  return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_item_ice_pearl_reduction:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_item_ice_pearl_reduction:StatusEffectPriority() return 1000 end
function modifier_item_ice_pearl_reduction:GetEffectName() return "particles/econ/items/crystal_maiden/ti7_immortal_shoulder/cm_ti7_immortal_frostbite.vpcf" end
function modifier_item_ice_pearl_reduction:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_ice_pearl_reduction:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor ("attack_speed_reduction") end
function modifier_item_ice_pearl_reduction:GetModifierMoveSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor ("move_speed_reduction") end

modifier_item_ice_pearl_active = class({})

function modifier_item_ice_pearl_active:IsPurgable() return false end
function modifier_item_ice_pearl_active:GetEffectName() return "particles/ice_pearl/ice_pearl_active.vpcf" end
function modifier_item_ice_pearl_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_ice_pearl_active:GetStatusEffectName() return "particles/status_fx/status_effect_frost_armor.vpcf" end
function modifier_item_ice_pearl_active:StatusEffectPriority() return 1000 end
function modifier_item_ice_pearl_active:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end

function modifier_item_ice_pearl_active:OnTakeDamage(params)
    if IsServer() then
        if params.unit == self:GetParent() and params.attacker ~= self:GetParent() and params.attacker:GetClassname() ~= "ent_dota_fountain" then

            ApplyDamage ({
                victim = params.attacker,
                attacker = self:GetParent(),
                damage = params.damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self:GetAbility(),
                damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_HPLOSS
            })
            EmitSoundOn("DOTA_Item.BladeMail.Damage", params.attacker)
        end
    end
end

modifier_item_ice_pearl_cooldown = class({})
function modifier_item_ice_pearl_cooldown:IsPurgable() return false end
function modifier_item_ice_pearl_cooldown:RemoveOnDeath() return false end
