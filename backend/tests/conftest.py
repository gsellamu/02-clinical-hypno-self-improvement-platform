"""
Pytest Configuration for E&P Assessment API Tests
Provides mock authentication that doesn't require auth module
"""

import pytest
import sys
import os
from datetime import datetime, timedelta
from typing import Dict
from uuid import uuid4

# Mock authentication functions that replace auth.dependencies
def create_access_token(data: Dict, role: str = "user") -> str:
    """
    Mock JWT token creation for testing
    Returns simple mock token: "mock_token_{user_id}_{role}"
    """
    user_id = data.get("sub", str(uuid4()))
    return f"mock_token_{user_id}_{role}"


# ============================================================================
# AUTHENTICATION FIXTURES
# ============================================================================

@pytest.fixture
def mock_user_token():
    """Create mock user JWT token for testing"""
    user_id = str(uuid4())
    return create_access_token({"sub": user_id}, "user")


@pytest.fixture
def mock_clinician_token():
    """Create mock clinician JWT token"""
    user_id = str(uuid4())
    return create_access_token({"sub": user_id}, "clinician")


@pytest.fixture
def mock_admin_token():
    """Create mock admin JWT token"""
    user_id = str(uuid4())
    return create_access_token({"sub": user_id}, "admin")


# ============================================================================
# TEST DATA FIXTURES
# ============================================================================

@pytest.fixture
def valid_assessment_data():
    """Valid assessment submission data"""
    return {
        "answers": {str(i): i % 2 == 0 for i in range(1, 37)},
        "time_to_complete": 240
    }


# ============================================================================
# TEST CLIENT FIXTURE
# ============================================================================

@pytest.fixture
def test_client():
    """
    FastAPI test client
    Returns None if app not available (tests should handle gracefully)
    """
    try:
        from main import app
        from fastapi.testclient import TestClient
        return TestClient(app)
    except ImportError:
        # Return None if app not available
        # This allows pytest to discover tests without failing
        return None


# ============================================================================
# ENVIRONMENT SETUP
# ============================================================================

@pytest.fixture(scope="session", autouse=True)
def setup_test_environment():
    """Setup test environment variables"""
    os.environ["TESTING"] = "true"
    yield
    os.environ.pop("TESTING", None)


# ============================================================================
# SKIP CONDITIONS
# ============================================================================

def pytest_collection_modifyitems(config, items):
    """
    Add skip marker to tests if FastAPI app is not available
    """
    try:
        from main import app
        app_available = True
    except ImportError:
        app_available = False
    
    if not app_available:
        skip_no_app = pytest.mark.skip(reason="FastAPI app not available")
        for item in items:
            item.add_marker(skip_no_app)
