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
    public float radius;
	// Use this for initialization
	void Start () {
        p = new ComputeBuffer(4 * 4 * 32 * 32, 36);//算出buffer数量
        kernel = comShader.FindKernel("CSMain");
        comShader.SetBuffer(kernel, "P", p);
        comShader.SetFloat("radius", radius);
    }
    
    private void OnRenderObject()
    {

        comShader.Dispatch(kernel, 32, 32, 1);

        mat.SetBuffer("P", p);

        comShader.SetVector("mousePos", point.position);
        comShader.SetFloat("deltaTime", Time.deltaTime);
        comShader.SetVector("originPos", transform.position);
        comShader.SetInt("init", init);

        mat.SetPass(0);

        Graphics.DrawProcedural(MeshTopology.Points, 4 * 4 * 32 * 32);
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
