# Metroid Clone

This project is a 2D Metroid-style platformer built in the Godot Engine, created as a technical showcase of my understanding of player movement, combat systems, enemy AI, physics interactions, lighting, and reusable level design tooling.

## Overview

The game features a single, self-contained level designed to exercise a variety of gameplay systems: precision platforming, mouse-aimed combat, proximity-based enemy behavior, dynamic lighting, and modular moving platforms. While intentionally scoped, the project focuses on building clean, extensible systems rather than content volume.

## Core Gameplay Systems:

### Player Movement and Platforming

The player controls a character composed of independent torso and leg sprites, which animate together based on movement and aim direction.

Key movement features include:

* **Variable jump height**
    * Jump height is controlled by how long the jump input is held. Releasing the jump button early applies a gravity multiplier to pull the player down faster, allowing for precise mid-air control.

* **Controlled falling behavior**
    * A maximum fall velocity is enforced to maintain consistent and predictable movement, preventing excessively fast descents.

* **Static and moving platforms**
    * The level contains a mix of static terrain and moving platforms that the player must use to access different areas.

This system mirrors platforming mechanics commonly found in Metroid-like games while emphasizing responsive control and predictable physics behavior.

---

### Combat System

Combat is intentionally constrained to reward positioning and timing.

*   **Mouse-aimed shooting**
    * The player aims using the mouse cursor. The character’s torso sprite rotates to face the cursor, and the bullet spawn point shifts dynamically based on aim direction.

*   **Single-shot weapon with reload delay**
    * The player may fire only one bullet at a time. After firing, a short reload delay prevents spamming and forces the player to reposition defensively if enemies get too close.

*   **Projectile-based damage**
    * Bullets are discrete entities that inflict damage upon colliding with enemies.

---

### Enemy AI: Exploding Drones

Enemy drones serve as both moving hazards and damage dealers, creating constant positional pressure on the player.

* **Proximity-based detection**
    * Drones monitor a detection radius and begin pursuing the player once they are within range.

* **Simple pursuit behavior**
    * Upon detecting the player, drones move toward them rather than firing projectiles, creating tension through movement instead of ranged combat.

* **Health-gated explosions**
    * Drones require three successful player shots to be destroyed.
    * When critically damaged, drones begin a visual “blink” phase before exploding.
    * Explosions damage anything within range, including:
        * The player
        * Other drones


## Level and Environment

### Playing in the Dark

One section of the level takes place in near-total darkness to demonstrate Godot’s 2D lighting capabilities and to alter player behavior.
* The level uses:
    * DirectionalLight2D
    * LightOccluder2D
    * PointLight2D

* The player must navigate using:
    * Their own light source
    * The faint red glow of enemy drones once detected

This section intentionally shifts gameplay from movement-focused to cautious exploration, reinforcing the importance of lighting as a gameplay mechanic rather than a purely visual feature.

---

### Moving Platforms and Level Tooling

Moving platforms are built as **reusable, designer-friendly systems** rather than one-off scripted behaviors.
* Platforms are controlled via `PlatformControlArea` nodes
* Control areas expose simple boolean flags such as:
    * Send Platform Down|Up
    * Toggle Horizontal|Vertical Movement
    * Stop|Start Vertical Movement
    * Stop|Start Horizontal Movement

This allows a non-technical level designer to place platforms and modify behavior without touching code, emphasizing authoring **flexibility and scalability**.

---

### Spawning & Restart Logic

**Player and Enemy Spawning**

* Marker2D nodes define spawn locations for:
    * The player
    * Enemy drones
* Enemies are instantiated dynamically at runtime based on these markers, making level iteration straightforward.

**Death & Restart**

* When the player dies:
    * They respawn at the designated player spawn point
    * All enemy drones are reset and respawned

This ensures consistent challenge and avoids partial or unpredictable game states after failure.

---

### Visual Feedback & Animation

**Damage feedback shaders**
* Both the player and enemy drones use a simple shader to flash white when taking damage, providing clear visual feedback.

**Death and explosion effects**
* Drone explosions are visually and mechanically distinct, reinforcing threat awareness and timing.

**Directional sprite control**
* The player’s sprite orientation and bullet spawn location continuously update based on mouse position, tightly coupling visuals with gameplay intent.

## Demo

#### Movement and Enemy Combat

![Metroid Start](./assets/gifs/metroid-start.gif)

#### Death and Plaform Movement

![Metroid Death](./assets/gifs/metroid-death.gif)

#### Playing in the Dark

![Metroid Restart](./assets/gifs/metroid-restart.gif)
