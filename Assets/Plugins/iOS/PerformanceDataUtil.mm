
#import <Foundation/Foundation.h>

#import <mach/mach.h>
#import <mach/mach_host.h>

#import <Metal/Metal.h>
#import <GPUUtilization/GPUUtilization.h>

/*
// Converts C style string to NSString
NSString* CreateNSString (const char* string)
{
	if (string)
		return [NSString stringWithUTF8String: string];
	else
		return [NSString stringWithUTF8String: ""];
}
*/
// Helper method to create C string copy
/*
//this does basicly the same thing as "strdup", that why you'll see this function call is commented out in _GetString
char* MakeStringCopy (const char* string)
{
	if (string == NULL)
		return NULL;
	
	char* res = (char*)malloc(strlen(string) + 1);
	strcpy(res, string);
	return res;
}
*/


// When native code plugin is implemented in .mm / .cpp file, then functions
// should be surrounded with extern "C" block to conform C function naming rules
extern "C" {
    float _GetCPUUsage() {
        kern_return_t kr;
        task_info_data_t tinfo;
        mach_msg_type_number_t task_info_count;
        
        task_info_count = TASK_INFO_MAX;
        kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }

        task_basic_info_t      basic_info;
        thread_array_t         thread_list;
        mach_msg_type_number_t thread_count;

        thread_info_data_t     thinfo;
        mach_msg_type_number_t thread_info_count;

        thread_basic_info_t basic_info_th;
        uint32_t stat_thread = 0; // Mach threads

        basic_info = (task_basic_info_t)tinfo;

        // get threads in the task
        kr = task_threads(mach_task_self(), &thread_list, &thread_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        if (thread_count > 0)
            stat_thread += thread_count;

        float tot_cpu = 0;
        int j;

        for (j = 0; j < thread_count; j++)
        {
            thread_info_count = THREAD_INFO_MAX;
            kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                             (thread_info_t)thinfo, &thread_info_count);
            if (kr != KERN_SUCCESS) {
                return -1;
            }

            basic_info_th = (thread_basic_info_t)thinfo;

            if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
                tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
            }

        } // for each thread

        kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
        assert(kr == KERN_SUCCESS);

        return tot_cpu;
    }

	float _GetMemoryUsage(){
        mach_task_basic_info_data_t info;
        mach_msg_type_number_t size = sizeof(info);
        kern_return_t kerr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size);
    
        if (kerr == KERN_SUCCESS) {
            // info.resident_size is in bytes; convert to megabytes
            return (double)info.resident_size / (1024 * 1024);
        } else {
            NSLog(@"Failed to fetch memory info: %s", mach_error_string(kerr));
            return 0.0;
        }
    }

    float _GetGPUUsage(){
                return GPUUtilization.gpuUsage;
    }
}

