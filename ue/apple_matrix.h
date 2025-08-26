//
// Apple-Compatible Matrix Implementation
// Replaces DirectX D3DMATRIX for Apple ARM64 compatibility
//

#ifndef APPLE_MATRIX_H
#define APPLE_MATRIX_H

#include <cmath>
#include <cstring>

// Custom 4x4 matrix structure to replace D3DMATRIX
// Maintains binary compatibility with DirectX D3DMATRIX layout
struct AppleMatrix {
    union {
        struct {
            float _11, _12, _13, _14;
            float _21, _22, _23, _24;
            float _31, _32, _33, _34;
            float _41, _42, _43, _44;
        };
        float m[4][4];
        float elements[16];
    };

    // Default constructor - initializes to identity matrix
    AppleMatrix() {
        memset(elements, 0, sizeof(elements));
        _11 = _22 = _33 = _44 = 1.0f;
    }

    // Constructor from array
    AppleMatrix(const float* data) {
        memcpy(elements, data, sizeof(elements));
    }

    // Copy constructor
    AppleMatrix(const AppleMatrix& other) {
        memcpy(elements, other.elements, sizeof(elements));
    }

    // Assignment operator
    AppleMatrix& operator=(const AppleMatrix& other) {
        if (this != &other) {
            memcpy(elements, other.elements, sizeof(elements));
        }
        return *this;
    }

    // Array access operators
    float* operator[](int row) {
        return m[row];
    }

    const float* operator[](int row) const {
        return m[row];
    }

    // Reset to identity matrix
    void identity() {
        memset(elements, 0, sizeof(elements));
        _11 = _22 = _33 = _44 = 1.0f;
    }

    // Matrix multiplication
    AppleMatrix operator*(const AppleMatrix& other) const {
        AppleMatrix result;
        
        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                result.m[i][j] = 0.0f;
                for (int k = 0; k < 4; k++) {
                    result.m[i][j] += m[i][k] * other.m[k][j];
                }
            }
        }
        
        return result;
    }

    // Matrix multiplication assignment
    AppleMatrix& operator*=(const AppleMatrix& other) {
        *this = *this * other;
        return *this;
    }
};

// Type alias to maintain compatibility with existing D3DMATRIX usage
using D3DMATRIX = AppleMatrix;

// Helper function to create a translation matrix
inline AppleMatrix CreateTranslationMatrix(float x, float y, float z) {
    AppleMatrix matrix;
    matrix._41 = x;
    matrix._42 = y;
    matrix._43 = z;
    return matrix;
}

// Helper function to create a rotation matrix from Euler angles
inline AppleMatrix CreateRotationMatrix(float pitch, float yaw, float roll) {
    AppleMatrix matrix;
    
    float sp = sinf(pitch);
    float cp = cosf(pitch);
    float sy = sinf(yaw);
    float cy = cosf(yaw);
    float sr = sinf(roll);
    float cr = cosf(roll);
    
    matrix._11 = cp * cy;
    matrix._12 = cp * sy;
    matrix._13 = sp;
    matrix._14 = 0.0f;
    
    matrix._21 = sr * sp * cy - cr * sy;
    matrix._22 = sr * sp * sy + cr * cy;
    matrix._23 = -sr * cp;
    matrix._24 = 0.0f;
    
    matrix._31 = -(cr * sp * cy + sr * sy);
    matrix._32 = cy * sr - cr * sp * sy;
    matrix._33 = cr * cp;
    matrix._34 = 0.0f;
    
    matrix._41 = 0.0f;
    matrix._42 = 0.0f;
    matrix._43 = 0.0f;
    matrix._44 = 1.0f;
    
    return matrix;
}

// Helper function to create a scaling matrix
inline AppleMatrix CreateScaleMatrix(float sx, float sy, float sz) {
    AppleMatrix matrix;
    matrix._11 = sx;
    matrix._22 = sy;
    matrix._33 = sz;
    return matrix;
}

#endif // APPLE_MATRIX_H