# Development Instructions for AI Agents

## Current Development Mode: NO BACKEND AVAILABLE

**IMPORTANT**: For current development, assume **NO BACKEND IS AVAILABLE**. All functionality must be workable without backend API for debugging purposes.

## Mock Mode Implementation

### Overview

The application is configured to work in **MOCK MODE** by default, which means:
- No real API calls are made
- Mock data is used for all features
- Authentication works with predefined test credentials
- All features can be tested without a backend server

### Mock Mode Configuration

Mock mode is controlled by the `useMockApi` flag in `lib/core/constants/app_constants.dart`:

```dart
static const bool useMockApi = true; // Set to false when backend is ready
```

### Mock Authentication

When mock mode is enabled, use the following test credentials:

**Admin User:**
- Username: `admin`
- Password: `admin123`

**Regular User:**
- Username: `user`
- Password: `user123`

**Viewer:**
- Username: `viewer`
- Password: `viewer123`

Any other credentials will be rejected with "Invalid username or password" error.

### Mock Data Providers

Mock implementations are provided in the following files:
- `lib/core/network/mock_auth_api.dart` - Mock authentication API
- Future mock providers will be added for:
  - Document management
  - Project/folder data
  - Upload queue simulation
  - Document scanning results

### Development Workflow

1. **Running the App**
   - The app works out-of-the-box in mock mode
   - No backend configuration needed
   - Use mock credentials to test all features

2. **Testing Features**
   - Login with any mock user credentials
   - Navigate through all screens
   - Test authentication flows
   - Verify role-based access control

3. **Switching to Real Backend**
   - Set `useMockApi = false` in AppConstants
   - Update `baseUrl` to point to your backend
   - Ensure backend implements the API contract from `/docs/API_SPECIFICATION.md`

### Architecture Notes

- Mock implementations follow the same interfaces as real implementations
- Repository layer handles switching between mock and real APIs
- No changes needed in presentation layer when switching modes
- Mock data is realistic and follows the same data models

### Adding New Mock Features

When implementing new features, always provide a mock implementation:

1. Create a mock API class in `lib/core/network/`
2. Implement the same methods as the real API
3. Return realistic mock data
4. Update the repository to check `useMockApi` flag
5. Document mock behavior in this file

### Backend Integration Checklist

When backend becomes available:

- [ ] Set `useMockApi = false` in AppConstants
- [ ] Update `baseUrl` with actual backend URL
- [ ] Verify all API endpoints match specification
- [ ] Test authentication with real credentials
- [ ] Test all features with real API
- [ ] Handle network errors appropriately
- [ ] Update this document with backend setup instructions

### Mock Mode Limitations

The following limitations exist in mock mode:
- Data is not persisted between app restarts (except tokens in secure storage)
- No real file uploads occur
- No actual PDF generation to server
- Project/folder data is static
- No real-time sync simulation

These limitations are acceptable for development and testing without a backend.

### Testing Instructions

For QA and testing purposes:
1. Use mock credentials provided above
2. Test all user roles (Admin, User, Viewer)
3. Verify navigation and UI flows
4. Test error handling with invalid credentials
5. Verify logout functionality
6. Test session persistence

### Environment Configuration

Current environment setup:
- **Development**: Mock mode enabled
- **Staging**: Mock mode disabled (when available)
- **Production**: Mock mode disabled (when available)

### Contact

For questions about mock mode or backend integration:
- Refer to `/docs/API_SPECIFICATION.md` for API contract
- Check `/docs/IMPLEMENTATION_STATUS.md` for current progress
- Review `/docs/DEVELOPMENT_PLAN.md` for roadmap
