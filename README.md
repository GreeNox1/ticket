# Ticket Booking App (Flutter + Bloc + Sqflite)

## Overview

Ushbu ilova kinoteatr o‘rindiqlarini band qilish tizimini taqdim etadi.  
Ilova foydalanuvchi va bot o‘rtasida o‘rindiq band qilish jarayonini simulyatsiya qiladi.  

- **State management**: `flutter_bloc`
- **Database**: `sqflite`
- **Logging**: `logbook`
- **UI**: Flutter GridView + Bottom Sheet

---

## Features

1. **Initial Seats Load**  
   - DB dan barcha o‘rindiqlarni o‘qib, GridView-da ko‘rsatadi.
   - Har o‘rindiq statusi: `available`, `locked`, yoki `reserved`.

2. **Lock & Reserve Seats**
   - Foydalanuvchi yoki bot o‘rindiqni `locked` qiladi.
   - `locked` o‘rindiq 10 soniya davomida band bo‘ladi.
   - Agar foydalanuvchi tasdiqlasa (`confirm`), o‘rindiq `reserved` bo‘ladi.
   - Timeout o‘tganda o‘rindiq avtomatik `available` holatga qaytadi.

3. **Bot Simulation**
   - Har 4 soniyada bot tasodifiy o‘rindiqni `locked` qiladi.
   - 50% ehtimol bilan bot o‘rindiqni `reserved` qiladi.
   - Timer va log bilan kuzatiladi.

4. **Lifecycle Handling**
   - Ilova minimizatsiyaga tushganda timerlar to‘xtatiladi.
   - Resume bo‘lganda timeout va expiration tekshiriladi.

5. **Database**
   - `sqflite` yordamida o‘rindiqlar statusi saqlanadi.
   - CRUD operatsiyalar amalga oshiriladi:
     - Read: `_readDataFromDB()`
     - Update single seat: `_updateDataFromDB()`
     - Clear all seats: `_updateAllDataFromDB()`

6. **Logging**
   - `logbook` paketidan foydalangan holda:
     - User va bot actionlari
     - Timeoutlar
     - DB operatsiyalari
   - Loglar konsolga yoziladi va UI-da real-time ko‘rsatish mumkin.

7. **UI**
   - GridView (8x8) o‘rindiqlar uchun.
   - Har o‘rindiq uchun `SeatButton` komponenti.
   - Bottom Sheet orqali o‘rindiqni `confirm` qilish mumkin.
