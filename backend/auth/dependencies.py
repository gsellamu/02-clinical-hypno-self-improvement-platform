"""
Authentication & Authorization Dependencies
JWT token validation and role-based access control
"""
from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from datetime import datetime, timedelta
import os


# Security
security = HTTPBearer()

# Configuration
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


# ============================================================================
# TOKEN UTILITIES
# ============================================================================

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def verify_token(token: str) -> dict:
    """Verify JWT token and return payload"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )


# ============================================================================
# DEPENDENCIES
# ============================================================================

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> dict:
    """
    Dependency to get current authenticated user
    
    Returns:
        dict: User information from JWT token
            {
                "id": "user-uuid",
                "email": "user@example.com",
                "role": "user"|"clinician"|"admin",
                "username": "username"
            }
    """
    token = credentials.credentials
    payload = verify_token(token)
    
    user_id = payload.get("sub")
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials"
        )
    
    return {
        "id": user_id,
        "email": payload.get("email"),
        "role": payload.get("role", "user"),
        "username": payload.get("username")
    }


def require_role(required_role: str):
    """
    Dependency factory to require specific role
    
    Usage:
        @router.get("/admin-only")
        async def admin_endpoint(
            current_user: dict = Depends(require_role("admin"))
        ):
            ...
    
    Args:
        required_role: Required role ("user", "clinician", "admin")
    
    Returns:
        Dependency function
    """
    async def role_checker(
        current_user: dict = Depends(get_current_user)
    ) -> dict:
        user_role = current_user.get("role", "user")
        
        # Role hierarchy: admin > clinician > user
        role_hierarchy = {
            "user": 1,
            "clinician": 2,
            "admin": 3
        }
        
        required_level = role_hierarchy.get(required_role, 1)
        user_level = role_hierarchy.get(user_role, 1)
        
        if user_level < required_level:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Insufficient permissions. Required role: {required_role}"
            )
        
        return current_user
    
    return role_checker


# ============================================================================
# MOCK AUTHENTICATION (For Development/Testing)
# ============================================================================

async def get_mock_user() -> dict:
    """
    Mock user for development/testing
    Remove this in production!
    """
    return {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "email": "test@example.com",
        "role": "user",
        "username": "testuser"
    }


async def get_mock_clinician() -> dict:
    """Mock clinician for testing"""
    return {
        "id": "660e8400-e29b-41d4-a716-446655440001",
        "email": "clinician@example.com",
        "role": "clinician",
        "username": "testclinician"
    }


async def get_mock_admin() -> dict:
    """Mock admin for testing"""
    return {
        "id": "770e8400-e29b-41d4-a716-446655440002",
        "email": "admin@example.com",
        "role": "admin",
        "username": "testadmin"
    }
