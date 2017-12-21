using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour {

    public ComputeShader comShader;
    public Shader shader;
    public Transform point;
    ComputeBuffer p;
    public Material mat;
    int kernel;
    int init = 0;
	// Use this for initialization
	void Start () {
        p = new ComputeBuffer(8 * 8 * 32 * 32, 12);
        kernel = comShader.FindKernel("CSMain");
        comShader.SetBuffer(kernel, "P", p);
    }
    
    private void OnRenderObject()
    {

        comShader.Dispatch(kernel, 32, 32, 1);

        mat.SetBuffer("P", p);

        comShader.SetVector("mousePos", point.position);
        comShader.SetVector("originPos", transform.position);
        comShader.SetInt("init", init);

        mat.SetPass(0);

        Graphics.DrawProcedural(MeshTopology.Points, 8 * 8 * 32 * 32);
        init = 1;
    }

    private void OnDestroy()
    {
        p.Release();
    }

    // Update is called once per frame
    void Update () {
        point.position = Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, transform.position.z - Camera.main.transform.position.z));
	}

}
