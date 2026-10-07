# Video "Đội Thủy Thần" — handoff notes

Language: reply to the user in Vietnamese.
Status (2026-10-07): script + role casting done. Next: run in Claude Desktop with Claude in Chrome
to generate voice, Kling images/clips, and assemble the final video.

## Concept
- Event: VNEXT CUP, 4 teams: Phong (wind), Hỏa (fire), Địa (earth), Thủy (water). User's team = **Thủy Thần**.
- Remake of the user's old 10s video (1280x720, 24fps): underwater Atlantis arena, light rays,
  bubbles, crowd in the stands; 5 sea warriors + 1 university student in a navy polo holding a rolled paper.
  Old video flow: group pose -> silver knight & red king dash swimming -> close-up merman & Aquaman -> group pose, student laughs.

## Casting (photo numbers = order the user sent the face photos)
| Role | Photo |
|---|---|
| A. Trident warrior, green scale armor, golden trident | 2 (grey suit) |
| B. Silver knight, full silver armor | 4 (bald selfie) |
| C. Red-armored king, crown, glowing blue energy orb | 3 (fringe, blue tie) |
| D. Green-skinned merman warrior, anchor (keep thin glasses) | 1 (thin glasses) |
| E. Aquaman, orange & green suit (keep thick black glasses) | 5 (thick glasses, airport) |
| F. ĐH Thủy Lợi student, navy polo — face of **Lợi** | 6 (brown blazer, dark bg) — user must re-send |

Face photos are NOT stored in git (privacy). Ask the user to upload them again.

## Dialogue (AI voice, Vietnamese, keep verbatim)
1. SV Thủy Lợi: "Bơi lội tung tăng đi các bạn ơi"
2. Poem:
   - Bọn mình cứ chill chill thế thôi
   - Vì biết cúp về tay ai rồi
   - Phong, Hoả, Địa như con tép
   - Vnext cúp này Thủy lên ngôi
3. Everyone: "Cho bọn em xin cái cúp 😂"

## Scenes (~15s, 16:9)
1. 0-3s: student waves & shouts line 1; silver knight + red king dash forward with bubble trails.
2. 3-6s: poem lines 1-2; team swims lazily, merman floats on his back, king juggles the orb.
3. 6-9s: poem line 3; close-up merman & Aquaman smirking, tiny shrimps swim across, crowd laughs.
4. 9-12s: poem line 4; heroic group pose, orb bursts blue light, text "VNEXT CUP – THỦY THẦN".
5. 12-15s: all six beg with palms together grinning; golden trophy sinks from above.

## Master image prompt (upload faces in order 1..6)
```
Epic underwater arena in Atlantis: glowing palace, sun rays from the surface, bubbles,
crowd cheering in the stands. Four team flags in the stands: wind, fire, earth, water.
Big banner "THỦY THẦN".
Six men in a row, keep each face EXACTLY like the reference photos:
- Photo 2: warrior in green scale armor holding a golden trident
- Photo 4 (bald): knight in full silver armor
- Photo 3: king in red armor with a crown, holding a glowing blue energy orb
- Photo 1 (thin glasses, keep glasses): green-skinned merman warrior holding an anchor
- Photo 5 (thick black glasses, keep glasses): Aquaman in orange-and-green suit
- Photo 6: university student in navy polo shirt, sitting on a rock holding a rolled paper
Cinematic, photorealistic, 16:9
```

## Plan for the local (Desktop) session
1. Crop faces (OpenCV 4.x Haar cascade; opencv 5 lacks CascadeClassifier), 512x512.
2. Voice: `edge-tts` with `vi-VN-NamMinhNeural` (blocked in cloud; should work locally).
3. Kling via Claude in Chrome (user logged in). Ask before every credit-spending generation;
   show the master image for approval before making clips.
4. Assemble with FFmpeg: clips + voice + poem subtitles + title text + background music -> MP4.
