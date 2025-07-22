# LensDataBase API Documentation v3.1

## Overview
This document describes the data structure and API endpoints used by the LensDataBase Swift Playground application for managing cinema lens databases.

## 📡 API Endpoints

### Base URL
```
https://api.lensdatabase.com/v3/
```

### Authentication
The API uses API key authentication. Include your API key in the request headers:
```http
Authorization: Bearer YOUR_API_KEY
X-API-Version: 3.1
```

## 📊 Database Structure

The database consists of three main tables that work together to provide comprehensive lens and rental information.

### 1. 🎯 Lenses Table
**Purpose**: Contains detailed specifications for cinema lenses.

#### Required Fields
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | String | Unique lens identifier | "L123" |
| `display_name` | String | User-friendly lens name | "Canon K35 24mm T1.3" |
| `manufacturer` | String | Lens manufacturer | "Canon" |
| `lens_name` | String | Lens model/series name | "K35" |
| `focal_length` | String | Focal length in mm | "24" |
| `aperture` | String | Maximum aperture f-stop | "1.3" |
| `format` | String | Sensor format compatibility | "FF", "S35", "MFT" |

#### Optional Fields
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `lens_format` | String | Additional format info | "Anamorphic" |
| `squeeze_factor` | String | Anamorphic squeeze ratio | "2.0" |
| `close_focus_in` | String | Min focus distance (inches) | "16" |
| `close_focus_cm` | String | Min focus distance (cm) | "40" |
| `image_circle` | String | Image circle diameter (mm) | "44" |
| `length` | String | Physical length (mm) | "110" |
| `front_diameter` | String | Front element diameter (mm) | "95" |
| `weight` | String | Weight in kg | "1.2" |

#### Format Categories
- **FF**: Full Frame (36x24mm)
- **S35**: Super 35 (24.9x18.7mm)
- **MFT**: Micro Four Thirds (17.3x13mm)
- **S16**: Super 16 (12.4x7.4mm)
- **Other**: Custom or specialty formats

### 2. 🏢 Rentals Table
**Purpose**: Information about rental houses and equipment providers.

#### Fields
| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| `id` | String | ✅ | Unique rental house ID | "5" |
| `name` | String | ✅ | Company name | "SuperRent" |
| `address` | String | ✅ | Physical address | "Москва, ул. Ленина, 1" |
| `phone` | String | ✅ | Contact phone | "+7 (999) 111-22-33" |
| `website` | String | ❌ | Company website | "https://superrent.ru" |

### 3. 📦 Inventory Table
**Purpose**: Links lenses to rental houses, showing availability.

#### Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | ✅ | Unique inventory record ID |
| `rental_id` | String | ✅ | Foreign key to rentals.id |
| `lens_id` | String | ✅ | Foreign key to lenses.id |
| `display_name` | String | ❌ | Custom display name override |
| `notes` | String | ❌ | Condition, availability notes |

## 🔗 API Endpoints

### Get All Data
**Endpoint**: `GET /database/dump`

**Description**: Returns complete database dump with all tables.

**Response Structure**:
```json
{
  "success": true,
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "3.1",
  "database": {
    "lenses": [...],
    "rentals": [...],
    "inventory": [...]
  },
  "metadata": {
    "total_lenses": 1250,
    "total_rentals": 45,
    "total_inventory_items": 3420,
    "last_updated": "2024-01-15T08:15:00Z"
  }
}
```

### Search Lenses
**Endpoint**: `GET /lenses/search`

**Parameters**:
- `q`: Search query string
- `format`: Filter by format (FF, S35, MFT, etc.)
- `manufacturer`: Filter by manufacturer
- `focal_min`: Minimum focal length
- `focal_max`: Maximum focal length
- `aperture_max`: Maximum aperture value
- `limit`: Results per page (default: 50, max: 200)
- `offset`: Pagination offset

**Example Request**:
```http
GET /lenses/search?q=canon&format=FF&focal_min=24&focal_max=85&limit=20
```

### Get Lens Details
**Endpoint**: `GET /lenses/{id}`

**Description**: Returns detailed information for a specific lens.

### Get Rental Information
**Endpoint**: `GET /rentals/{id}`

**Description**: Returns rental house details and available inventory.

### Get Camera Compatibility
**Endpoint**: `GET /cameras/compatibility`

**Description**: Returns camera sensor data for lens compatibility calculations.

## 📋 Example API Responses

### Complete Database Dump
```json
{
  "success": true,
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "3.1",
  "database": {
    "lenses": [
      {
        "id": "L123",
        "display_name": "Canon K35 24mm T1.3",
        "manufacturer": "Canon",
        "format": "FF",
        "lens_format": "",
        "lens_name": "K35",
        "focal_length": "24",
        "aperture": "1.3",
        "squeeze_factor": "",
        "close_focus_in": "16",
        "close_focus_cm": "40",
        "image_circle": "44",
        "length": "110",
        "front_diameter": "95",
        "weight": "1.2"
      },
      {
        "id": "L124",
        "display_name": "Zeiss Master Prime 35mm T1.3",
        "manufacturer": "Zeiss",
        "format": "FF",
        "lens_format": "",
        "lens_name": "Master Prime",
        "focal_length": "35",
        "aperture": "1.3",
        "squeeze_factor": "",
        "close_focus_in": "12",
        "close_focus_cm": "30",
        "image_circle": "46.3",
        "length": "118",
        "front_diameter": "95",
        "weight": "1.6"
      }
    ],
    "rentals": [
      {
        "id": "5",
        "name": "SuperRent",
        "address": "Москва, ул. Ленина, 1",
        "phone": "+7 (999) 111-22-33",
        "website": "https://superrent.ru"
      },
      {
        "id": "6",
        "name": "CineTech Rentals",
        "address": "СПб, Невский пр., 100",
        "phone": "+7 (812) 555-0123",
        "website": "https://cinetech-rentals.ru"
      }
    ],
    "inventory": [
      {
        "id": "17",
        "rental_id": "5",
        "lens_id": "L123",
        "display_name": "",
        "notes": "Без царапин, отличное состояние"
      },
      {
        "id": "18",
        "rental_id": "5",
        "lens_id": "L124",
        "display_name": "",
        "notes": "Новый комплект, калибровка 2024"
      },
      {
        "id": "19",
        "rental_id": "6",
        "lens_id": "L123",
        "display_name": "",
        "notes": "Рабочее состояние"
      }
    ]
  },
  "metadata": {
    "total_lenses": 2,
    "total_rentals": 2,
    "total_inventory_items": 3,
    "last_updated": "2024-01-15T08:15:00Z"
  }
}
```

### Search Results
```json
{
  "success": true,
  "query": {
    "q": "canon",
    "format": "FF",
    "focal_min": 24,
    "focal_max": 85
  },
  "results": {
    "total": 12,
    "limit": 20,
    "offset": 0,
    "lenses": [
      {
        "id": "L123",
        "display_name": "Canon K35 24mm T1.3",
        "manufacturer": "Canon",
        "focal_length": "24",
        "aperture": "1.3",
        "format": "FF"
      }
    ]
  }
}
```

## 🛠️ Implementation Notes

### Data Types
- **All fields are strings** for consistency, even numeric values
- **Empty strings** are used instead of null values
- **Foreign keys** use string IDs for maximum compatibility

### Relationships
- `inventory.rental_id` → `rentals.id`
- `inventory.lens_id` → `lenses.id`

### Performance Considerations
- Use pagination for large result sets
- Cache database dumps when possible
- Implement local search for better user experience

### Error Handling
```json
{
  "success": false,
  "error": {
    "code": "LENS_NOT_FOUND",
    "message": "Lens with ID 'L999' not found",
    "details": "The requested lens ID does not exist in the database"
  }
}
```

## 🔄 Client Implementation (Swift)

### Network Service Example
```swift
class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://api.lensdatabase.com/v3"
    private let apiKey = "YOUR_API_KEY"
    
    func fetchAllData() async throws -> DatabaseResponse {
        var request = URLRequest(url: URL(string: "\(baseURL)/database/dump")!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("3.1", forHTTPHeaderField: "X-API-Version")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(DatabaseResponse.self, from: data)
    }
}
```

### Data Models
```swift
struct DatabaseResponse: Codable {
    let success: Bool
    let timestamp: String?
    let version: String?
    let database: Database
    let metadata: Metadata?
}

struct Database: Codable {
    let lenses: [Lens]
    let rentals: [Rental]
    let inventory: [Inventory]
}

struct Metadata: Codable {
    let totalLenses: Int
    let totalRentals: Int
    let totalInventoryItems: Int
    let lastUpdated: String
    
    private enum CodingKeys: String, CodingKey {
        case totalLenses = "total_lenses"
        case totalRentals = "total_rentals"
        case totalInventoryItems = "total_inventory_items"
        case lastUpdated = "last_updated"
    }
}
```

## 📝 Integration Checklist

### For Mobile Applications
- [ ] Implement proper API key management
- [ ] Add offline data caching
- [ ] Handle network timeouts gracefully
- [ ] Implement incremental data updates
- [ ] Add search result pagination
- [ ] Cache lens images locally

### For Web Applications
- [ ] Implement CORS handling
- [ ] Add request rate limiting
- [ ] Cache responses appropriately
- [ ] Handle API versioning
- [ ] Implement error boundaries

## 🚀 Future API Enhancements

### Planned Features
- **Image URLs**: Direct links to lens images
- **Specifications**: Extended technical specifications
- **Reviews**: User reviews and ratings
- **Availability**: Real-time rental availability
- **Pricing**: Rental pricing information
- **Alternatives**: Suggested alternative lenses

### Version Roadmap
- **v3.2**: Image support and extended metadata
- **v3.3**: Real-time availability updates
- **v4.0**: GraphQL API support

---

**Documentation Version**: 3.1  
**Last Updated**: January 2024  
**API Support**: api-support@lensdatabase.com