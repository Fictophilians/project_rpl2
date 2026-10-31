# Changelog

All notable changes to the GameHaven project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-31

### Added
- Complete Game Catalog vault with CRUD operations (Add, Edit, Delete, Read).
- Game rating score input support with fine granularity (`0.0` - `10.0`).
- Role-based authorization (`admin` vs `user`):
  - Admins can manage games and view/delete registered users.
  - Standard users have read-only catalog exploration and profile access.
- Cloudinary profile photo upload integration with multipart headers and MIME type fallback validation.
- Responsive layout support:
  - Mobile compact list.
  - Tablet 2-column view.
  - Desktop 3-column gaming library grid with dock navigation.
- Real-time search filter for game title and developer.
- JWT persistent session management via `SharedPreferences`.
- MIT License and comprehensive setup documentation.
