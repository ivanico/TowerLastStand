extends Node

enum GamePhase     { WAVE, DRAFT, BOSS, DEFEAT, VICTORY }
enum DamageType    { NORMAL, PIERCING, MAGIC, SIEGE, CHAOS }
enum ArmorType     { UNARMORED, LIGHT, MEDIUM, HEAVY }
enum SpellCategory { PROJECTILE, AOE_BURST, PERSISTENT_ZONE, CHAIN, MINE, PASSIVE, STAT_BOOST }
enum EnemyType     { GRUNT, RUNNER, BRUTE, FLYER, ELITE, BOSS }
enum TargetMode    { CLOSEST, LOWEST_HP, HIGHEST_HP, FIRST }
enum CardRarity    { COMMON, RARE, EPIC }
enum SynergyTag    { FIRE, CHAIN, PIERCING, HEAVY, ARMOR, OFFENSE, UTILITY, GOLD, CHAOS_TAG }
enum TowerID       { IRONCLAD, EMBER, TIDE, SENTINEL, PHANTOM }
enum MaterialType  { CHAPTER_MAT, UNIVERSAL_MAT }

const WAVE_DURATION_MAX:     float = 30.0
const TOTAL_WAVES:           int   = 20
const DRAFT_CARDS_SHOWN:     int   = 3
const ENEMY_HP_SCALE:        float = 1.12
const ENEMY_DMG_SCALE:       float = 1.08
const XP_PER_KILL_BASE:      int   = 10
const XP_PER_LEVEL_BASE:     int   = 100
const MAX_SPELL_SLOTS:       int   = 12
const MAX_MINES:             int   = 10
const SYNERGY_THRESHOLD_LOW: int   = 3
const SYNERGY_THRESHOLD_HIGH:int   = 5
const TOWER_MAX_STARS:       int   = 5
const SPELL_MAX_RANK:        int   = 5
const MAX_ENERGY:            int   = 5
