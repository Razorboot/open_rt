# OpenRT
---

![open_rt_background](assets/open_rt_background.png)

---

> # Introduction
### What is OpenRT?
OpenRT is a object-oriented retro-style **WIP realtime rendering engine** that utilizes multiple **performance-heavy graphics techniques and optimization strategies.** As a result, **you'll likely encounter lag depending on the complexity of your experience and many features may be buggy and are subject to change**, so feel free to create issues on the Github repo when you encounter bugs!

You can download the engine from the Github repo here.
### Important Features:
OpenRT works by splitting up the rendering pipeline into four main **main user-facing modules:** "Core", "MaterialsContext", "RenderContext", and "LightingContext", which are further subdivided into "Materials", "Lights", and "Textures". It exposes a complete API for controlling lighting, adjusting render behavior, setting materials, and controlling resolution, and the ability to add to or change the per-pixel rendering pipeline.



OpenRT currently supports:
- Multithreading
- Global lights (sun)
- Local lights (PointLights only at the moment)
- Direct Illumination (diffuse, specular, hard shadows)
- Custom Materials (with albedo, specular, and normal maps)
- Interlacing (for performance and style!)

---

> # Getting Started
> Learn how to set up a new experience with OpenRT.
