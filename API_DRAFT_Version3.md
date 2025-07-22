# LKS Rental API — Черновик структуры ответа

## Пример запроса

```
GET https://lksrental.site/api.php?action=all
```

---

## Пример ответа

```json
{
  "success": true,
  "database": {
    "inventory": [
      {
        "id": 1,
        "rental_id": "R001",
        "lens_id": "L061",
        "display_name": "ARRI: Signature Prime 15mm",
        "notes": "LKSrental"
      }
      // ... другие inventory
    ],
    "lenses": [
      {
        "id": "L001",
        "format": "Spherical Prime ",
        "manufacturer": "Ancient Optics",
        "lens_name": "Petzvalux ",
        "focal_length": "27mm",
        "aperture": "T1.7",
        "squeeze_factor": "Spherical",
        "close_focus_in": "12\"",
        "close_focus_cm": "",
        "image_circle": "43.3",
        "length": "120",
        "front_diameter": "136",
        "display_name": "Ancient Optics: Petzvalux  27mm",
        "weight": "",
        "lens_format": "FF"
      }
      // ... другие lenses
    ],
    "rentals": [
      {
        "id": "R011",
        "name": "SkyRental",
        "address": "Москва, 2-й Донской пр., 9Б",
        "phone": "+7(965) 370 50 50",
        "website": "https://skyrental.ru/"
      }
      // ... другие rentals
    ]
  }
}
```

---

## Описание структуры

### inventory (Массив объектов инвентаря)
- **id**: числовой идентификатор записи
- **rental_id**: ID рентал-компании
- **lens_id**: ID линзы (объектива)
- **display_name**: строка для отображения (марка, модель, фокусное)
- **notes**: комментарий

### lenses (Массив описаний объективов)
- **id**: уникальный ID линзы
- **format**: тип объектива (например, "Spherical Prime")
- **manufacturer**: производитель
- **lens_name**: название линзы/серии
- **focal_length**: фокусное расстояние ("27mm" и т.п.)
- **aperture**: светосила ("T1.7")
- **squeeze_factor**: анаморфотный коэффициент или "Spherical"
- **close_focus_in**: минимальная дистанция фокусировки (дюймы)
- **close_focus_cm**: минимальная дистанция фокусировки (см)
- **image_circle**: диаметр кругового изображения (мм)
- **length**: длина объектива (мм)
- **front_diameter**: диаметр переднего элемента (мм)
- **display_name**: строка для отображения
- **weight**: вес (если указан)
- **lens_format**: формат ("FF", "S35" и пр.)

### rentals (Массив рентал-компаний)
- **id**: уникальный ID рентала
- **name**: название компании
- **address**: адрес
- **phone**: телефон
- **website**: сайт

---

## Пример объекта inventory

```json
{
  "id": 1,
  "rental_id": "R001",
  "lens_id": "L061",
  "display_name": "ARRI: Signature Prime 15mm",
  "notes": "LKSrental"
}
```

## Пример объекта lenses

```json
{
  "id": "L001",
  "format": "Spherical Prime ",
  "manufacturer": "Ancient Optics",
  "lens_name": "Petzvalux ",
  "focal_length": "27mm",
  "aperture": "T1.7",
  "squeeze_factor": "Spherical",
  "close_focus_in": "12\"",
  "close_focus_cm": "",
  "image_circle": "43.3",
  "length": "120",
  "front_diameter": "136",
  "display_name": "Ancient Optics: Petzvalux  27mm",
  "weight": "",
  "lens_format": "FF"
}
```

## Пример объекта rentals

```json
{
  "id": "R011",
  "name": "SkyRental",
  "address": "Москва, 2-й Донской пр., 9Б",
  "phone": "+7(965) 370 50 50",
  "website": "https://skyrental.ru/"
}
```

---

## Примечания

- Все поля могут быть пустыми, если данных нет.
- Для получения всех данных используйте запрос выше, для выборки по конкретному rental или lens фильтруйте массивы по нужному ID.

---

**Это черновик — если появятся новые поля или примеры, просто дополни!**