using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Runtime.InteropServices;

public class CallPlugInMethods : MonoBehaviour
{

	#region DllImport
	/* Interface to native implementation */
	[DllImport("__Internal")]
	private static extern float _GetCPUUsage();

	[DllImport("__Internal")]
	private static extern float _GetMemoryUsage();


	[DllImport("__Internal")]
	private static extern float _GetGPUUsage();

	/* Public interface for use inside C# / JS code */
	#endregion


	[SerializeField] private Text text;
	private bool isTracking = false;
	private string dataSummary;
	int dataPoints;
	float minCPU, averageCPU, maxCPU;
	float minRAM, averageRAM, maxRAM;
	float minGPU, averageGPU, maxGPU;

	public void StartTracking()
	{
		if (isTracking)
		{
			text.text = "Tracking In progress, press the stop button to review data.";
			return;
		}
		isTracking = true;
		StartCoroutine(GetInfo());
		//Start Tracking
	}

	public void StopTracking()
	{
		if (!isTracking)
		{
			text.text = "Not currently tracking";
			return;
		}

		isTracking = false;

	}

	private void UpdateText()
	{
		text.text = "Usage Summary: \n";
		text.text += $"CPU: \n Min: {minCPU} %\n Avg: {averageCPU} %\n Max: {maxCPU} %\n";
		text.text += $"Ram: \n Min: {minRAM} MB,\n Avg: {averageRAM} MB\n Max: {maxRAM} MB\n";
		text.text += $"CPU: \n Min: {minGPU} %\n Avg: {averageGPU} %\n Max: {maxGPU} %";
	}

	IEnumerator GetInfo()
	{

		float cpu, gpu, ram;
		while (isTracking)
		{
			cpu = _GetCPUUsage();
			gpu = _GetGPUUsage();
			ram = _GetMemoryUsage();

			minCPU = IfMin(cpu, minCPU);
			minGPU = IfMin(gpu, minGPU);
			minRAM = IfMin(ram, minRAM);


			maxCPU = IfMax(cpu, maxCPU);
			maxGPU = IfMax(gpu, maxGPU);
			maxRAM = IfMax(ram, maxRAM);


			averageCPU = NewAverage(cpu, averageCPU);
			averageGPU = NewAverage(gpu, averageGPU);
			averageRAM = NewAverage(ram, averageRAM);
			dataPoints++;
			yield return new WaitForEndOfFrame();
		}
		UpdateText();
		yield return null;
	}

	private float IfMin(float newValue, float oldValue)
	{
		if (newValue < oldValue)
		{
			return newValue;
		}

		return oldValue;
	}


	private float IfMax(float newValue, float oldValue)
	{
		if (newValue > oldValue)
		{
			return newValue;
		}

		return oldValue;
	}

	private float NewAverage(float newValue,float oldValue){
		return ((oldValue * dataPoints) + newValue) / (dataPoints+1);
	}
}
