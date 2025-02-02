manhattan_mind_explosion = class({})

function manhattan_mind_explosion:OnSpellStart()
    local target = self:GetCursorTarget():GetAbsOrigin()
    local particle1 =  ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_CUSTOMORIGIN, self:GetCursorTarget())
    ParticleManager:SetParticleControl(particle1, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle1, 1, Vector(target.x, target.y, target.z + 64))
    ParticleManager:ReleaseParticleIndex(particle1)

    EmitSoundOn("Ability.LagunaBladeImpact", self:GetCursorTarget())

    local damage = self:GetSpecialValueFor("damage") + self:GetCaster():GetMana() / 100 * self:GetSpecialValueFor("mana_damage_pct")
    ApplyDamage({
        victim = self:GetCursorTarget(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self
    })

    local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN, self:GetCursorTarget())
    ParticleManager:SetParticleControl(particle2, 0, self:GetCursorTarget():GetAbsOrigin())

    self:GetCursorTarget():SpendMana(damage, self)
end
