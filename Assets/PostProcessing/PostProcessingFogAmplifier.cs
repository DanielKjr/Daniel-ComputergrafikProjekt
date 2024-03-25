using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteAlways]
public class PostProcessingFogAmplifier : MonoBehaviour
{
    [SerializeField] private Material _colorAdjustmentMaterial = null;
    [SerializeField, Range(0, 2)] private float _size = 0.5f;
    [SerializeField, Range(0, 2)] private float _fogStrength = 1f;
    [SerializeField, Range(1, 5)] private float _xMovement = 1f;
    [SerializeField, Range(1, 5)] private float _yMovement = 1f;

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        _colorAdjustmentMaterial.SetFloat("_Size", _size);
        _colorAdjustmentMaterial.SetFloat("_FogStrength", _fogStrength);
        _colorAdjustmentMaterial.SetFloat("_XMovement", _xMovement);
        _colorAdjustmentMaterial.SetFloat("_YMovement", _yMovement);
        
        Graphics.Blit(src, dst, _colorAdjustmentMaterial);
    }
}
