//
//  SceneUtil.m
//  OpenGL ES Test
//
//  Created by 卢育彪 on 2018/12/14.
//  Copyright © 2018年 luyubiao. All rights reserved.
//

#import "SceneUtil.h"

#pragma mark - Triangle

SceneTriangle SceneTriangleMake(const SceneVertex vertexA, const SceneVertex vertexB, const SceneVertex vertexC)
{
    SceneTriangle result;
    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;
    return result;
}

GLKVector3 SceneTriangleFaceNormal(const SceneTriangle triangle)
{
    GLKVector3 vertorA = GLKVector3Subtract(triangle.vertices[1].position, triangle.vertices[0].position);
    GLKVector3 vertorB = GLKVector3Subtract(triangle.vertices[2].position, triangle.vertices[0].position);
    return SceneVector3UnitNormal(vertorA, vertorB);
}

void SceneTrianglesUpdateFaceNormals(SceneTriangle someTriangles[NUM_FACES])
{
    for (int i = 0; i < NUM_FACES; i++) {
        GLKVector3 faceNormal = SceneTriangleFaceNormal(someTriangles[i]);
        someTriangles[i].vertices[0].normal = faceNormal;
        someTriangles[i].vertices[1].normal = faceNormal;
        someTriangles[i].vertices[2].normal = faceNormal;
    }
}

void SceneTrianglesUpdateVertexNormals(SceneTriangle someTriangles[NUM_FACES])
{
    SceneVertex newVertexA = vertexA;
    SceneVertex newVertexB = vertexB;
    SceneVertex newVertexC = vertexC;
    SceneVertex newVertexD = vertexD;
    
    SceneVertex newVertexE = someTriangles[3].vertices[0];
    NSLog(@"x---%f", someTriangles[3].vertices[0].position.x);
    NSLog(@"y---%f", someTriangles[3].vertices[0].position.y);
    NSLog(@"z---%f", someTriangles[3].vertices[0].position.z);
    
    SceneVertex newVertexF = vertexF;
    SceneVertex newVertexG = vertexG;
    SceneVertex newVertexH = vertexH;
    SceneVertex newVertexI = vertexI;
    
    GLKVector3 faceNormals[NUM_FACES];
    for (int i = 0; i < NUM_FACES; i++) {
        faceNormals[i] = SceneTriangleFaceNormal(someTriangles[i]);
    }
    
    newVertexA.normal = faceNormals[0];
    newVertexB.normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(faceNormals[0], faceNormals[1]), faceNormals[2]), faceNormals[3]), 0.25);
    newVertexC.normal = faceNormals[1];
    newVertexD.normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(faceNormals[0], faceNormals[2]), faceNormals[4]), faceNormals[6]), 0.25);
    newVertexE.normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(faceNormals[2], faceNormals[3]), faceNormals[4]), faceNormals[5]), 0.25);
    newVertexF.normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(faceNormals[1], faceNormals[3]), faceNormals[5]), faceNormals[7]), 0.25);
    newVertexG.normal = faceNormals[6];
    newVertexH.normal = GLKVector3MultiplyScalar(GLKVector3Add(GLKVector3Add(GLKVector3Add(faceNormals[4], faceNormals[5]), faceNormals[6]), faceNormals[7]), 0.25);
    newVertexI.normal = faceNormals[7];
    
    
    someTriangles[0] = SceneTriangleMake(newVertexA, newVertexB, newVertexD);
    someTriangles[1] = SceneTriangleMake(newVertexB, newVertexC, newVertexF);
    someTriangles[2] = SceneTriangleMake(newVertexD, newVertexB, newVertexE);
    someTriangles[3] = SceneTriangleMake(newVertexE, newVertexB, newVertexF);
    someTriangles[4] = SceneTriangleMake(newVertexD, newVertexE, newVertexH);
    someTriangles[5] = SceneTriangleMake(newVertexE, newVertexF, newVertexH);
    someTriangles[6] = SceneTriangleMake(newVertexG, newVertexD, newVertexH);
    someTriangles[7] = SceneTriangleMake(newVertexH, newVertexF, newVertexI);
}

void SceneTrianglesNormalLinesUpdate(const SceneTriangle someTriangles[NUM_FACES], GLKVector3 lightPosition, GLKVector3 someNormalLineVertices[NUM_LINE_VERTS])
{
    int trianglesIndex;
    int lineVetexIndex = 0;
    
    for (trianglesIndex = 0; trianglesIndex < NUM_FACES; trianglesIndex++) {
        someNormalLineVertices[lineVetexIndex++] = someTriangles[trianglesIndex].vertices[0].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(someTriangles[trianglesIndex].vertices[0].position, GLKVector3MultiplyScalar(someTriangles[trianglesIndex].vertices[0].normal, 0.5));
        someNormalLineVertices[lineVetexIndex++] = someTriangles[trianglesIndex].vertices[1].position;
        GLKVector3Add(someTriangles[trianglesIndex].vertices[1].position, GLKVector3MultiplyScalar(someTriangles[trianglesIndex].vertices[1].normal, 0.5));
        someNormalLineVertices[lineVetexIndex++] = someTriangles[trianglesIndex].vertices[2].position;
        GLKVector3Add(someTriangles[trianglesIndex].vertices[2].position, GLKVector3MultiplyScalar(someTriangles[trianglesIndex].vertices[2].normal, 0.5));
    }
    
    someNormalLineVertices[lineVetexIndex++] = lightPosition;
    someNormalLineVertices[lineVetexIndex] = GLKVector3Make(0.0, 0.0, -0.5);
}

GLKVector3 SceneVector3UnitNormal(const GLKVector3 vectorA, const GLKVector3 vectorB)
{
    return GLKVector3Normalize(GLKVector3CrossProduct(vectorA, vectorB));
}
